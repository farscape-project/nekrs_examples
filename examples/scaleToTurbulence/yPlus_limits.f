C-----------------------------------------------------------------------
      subroutine y_p_limits(wd,ifdef)
      implicit none
      include 'SIZE'
      include 'TOTAL'
C
C     NOTE: min value should work if domain has internal corners
C
      logical ifdef,ifut,iftl,ifpsp(ldimt-1)
      common /y_p_print/ ifut,iftl,ifpsp

      character*15 pname
      integer e,i,i0,i1,j,j0,j1,k,k0,k1,iw,jw,kw,i2,j2
      integer isd,ifld
c     integer estrd,ipt,wpt
      real msk(lx1,ly1,lz1,lelv)
      real gradu(lx1,ly1,lz1,3,3),wd(lx1,ly1,lz1,lelv)
      real tau(3),norm(3),vsca,tauw
      real utau,rho,mu,lambda,cp,Pra,yp,tl,psp,Sc(ldimt-1)
      real ypmin,ypmax,ypave,vol,utmin,utmax,utave,tlmin,tlmax,tlave
      real spmin(ldimt-1),spmax(ldimt-1),spave(ldimt-1)
      real glmin,glmax,glsum
      logical ifgrad, ifdid

      data ifdid /.false./
      save ifdid, msk

C     do some initializations once
      if(.not.ifdid)then

C       set flags for values to calculate and print
        ifdid=.true.
        if(ifdef)then
          ifut=.true.
          if(if3d) ifut=.false.
          iftl=.false.
          if(ifheat.and.(idpss(1).ge.0))iftl=.true.
          do i=1,ldimt-1
            ifpsp(i)=.false.
          enddo
        endif

C       build the mask  (this mask ignores some points which maybe important... 
        call rone(msk,lx1*ly1*lz1*nelv)    ! need to look at it more closely)
        do e=1,nelv
          do isd=1,2*ndim
            if(cbc(isd,e,1).eq.'W  ') then
              call backpts(i0,i1,j0,j1,k0,k1,isd)
              do k=k0,k1
              do j=j0,j1
              do i=i0,i1
                msk(i,j,k,e)=0.0
              enddo
              enddo
              enddo
            endif
          enddo
          do isd=1,2*ndim
            if(cbc(isd,e,1).eq.'W  ') then
              call facind(i0,i1,j0,j1,k0,k1,lx1,ly1,lz1,isd)
              do k=k0,k1
              do j=j0,j1
              do i=i0,i1
                msk(i,j,k,e)=1.0
              enddo
              enddo
              enddo
            endif
          enddo
        enddo
        call dssum(msk,lx1,ly1,lz1) !for elements with edges but not faces along a wall
      endif

C     initialize the variables AFTER the flags are set
      ypmin=1.0e10
      ypmax=-1.0e10
      ypave=0.0
      utmin=1.0e10
      utmax=-1.0e10
      utave=0.0
      tlmin=1.0e10
      tlmax=-1.0e10
      tlave=0.0
      do ifld=1,ldimt-1
        if(ifpsp(ifld))then
          spmin(ifld)=1.0e10
          spmax(ifld)=-1.0e10
          spave(ifld)=0.0
        endif
      enddo
      vol=0.0

C     Now do the thing
      do e=1,nelv
        ifgrad=.true.
        do isd=1,2*ndim
          if(cbc(isd,e,1).eq.'W  ')then
            if(ifgrad)then
              call gradm11(gradu(1,1,1,1,1)
     &                    ,gradu(1,1,1,1,2)
     &                    ,gradu(1,1,1,1,3),vx,e)
              call gradm11(gradu(1,1,1,2,1)
     &                    ,gradu(1,1,1,2,2)
     &                    ,gradu(1,1,1,2,3),vy,e)
              if(if3d)
     &          call gradm11(gradu(1,1,1,3,1)
     &                      ,gradu(1,1,1,3,2)
     &                      ,gradu(1,1,1,3,3),vz,e)
              ifgrad=.false.
            endif
            call backpts(i0,i1,j0,j1,k0,k1,isd)
            do k=k0,k1
            do j=j0,j1
            do i=i0,i1
              if(msk(i,j,k,e).lt.0.5) then
                iw=i
                jw=j
                kw=k
                if    (isd.eq.1) then
                  jw=1
                elseif(isd.eq.2) then
                  iw=lx1
                elseif(isd.eq.3) then
                  jw=ly1
                elseif(isd.eq.4) then
                  iw=1
                elseif(isd.eq.5) then
                  kw=1
                else
                  kw=lz1
                endif
                call getSnormal(norm,iw,jw,kw,isd,e)

                mu=cpfld(1,1)
                rho=cpfld(1,2)
                Pra=1.0
                if(iftl) then
                  lambda=cpfld(2,1)
                  cp=cpfld(2,2)/rho
                  Pra=cp*mu/lambda
                endif
                do ifld=3,ldimt+1
                  if(ifpsp(ifld-2))then
                    Sc(ifld-2)=vtrans(iw,jw,kw,e,ifld)*mu/(rho*
     &                                           vdiff(iw,jw,kw,e,ifld))
                  endif
                enddo

                do i2=1,ldim
                tau(i2)=0.0
                  do j2=1,ldim
                    tau(i2)=tau(i2)+mu*norm(j2)*
     &                     (gradu(iw,jw,kw,i2,j2)+gradu(iw,jw,kw,j2,i2))
                  enddo
                enddo

                vsca=0.0
                do i2=1,ldim
                  vsca=vsca+tau(i2)*norm(i2)
                enddo

                tauw=0.0
                do i2=1,ldim
                  tauw=tauw+(tau(i2)-vsca*norm(i2))**2
                enddo
                tauw=sqrt(tauw)
                utau=sqrt(tauw/rho)
                yp=wd(i,j,k,e)*utau*rho/mu
                ypmin=min(ypmin,yp)
                ypmax=max(ypmax,yp)
                ypave=ypave+yp*bm1(i,j,k,e)
                vol=vol+bm1(i,j,k,e)
                if(ifut)then
                  utmin=min(utau,utmin)
                  utmax=max(utau,utmax)
                  utave=utave+utau*bm1(i,j,k,e)
                endif
                if(iftl)then
                  tl=yp*Pra
                  tlmin=min(tlmin,tl)
                  tlmax=max(tlmax,tl)
                  tlave=tlave+tl*bm1(i,j,k,e)
                endif
                do ifld=1,ldimt-1
                  if(ifpsp(ifld))then
                    psp=yp*Sc(ifld)
                    spmin(ifld)=min(spmin(ifld),psp)
                    spmax(ifld)=max(spmax(ifld),psp)
                    spave(ifld)=spave(ifld)+psp*bm1(i,j,k,e)
                  endif
                enddo
              endif
            enddo
            enddo
            enddo
          endif
        enddo
      enddo

      ypmin=glmin(ypmin,1)
      ypmax=glmax(ypmax,1)
      ypave=glsum(ypave,1)
      vol=glsum(vol,1)
      ypave=ypave/vol
      if(ifut)then
        utmin=glmin(utmin,1)
        utmax=glmax(utmax,1)
        utave=glsum(utave,1)
        utave=utave/vol 
      endif
      if(iftl)then
        tlmin=glmin(tlmin,1)
        tlmax=glmax(tlmax,1)
        tlave=glsum(tlave,1)
        tlave=tlave/vol
      endif
      do ifld=1,ldimt-1
        if(ifpsp(ifld))then
          spmin(ifld)=glmin(spmin(ifld),1)
          spmax(ifld)=glmax(spmax(ifld),1)
          spave(ifld)=glsum(spave(ifld),1)
          spave(ifld)=spave(ifld)/vol
        endif
      enddo

      if(nio.eq.0)then
        write(*,255) 'y_p+',ypmin,ypmax,ypave
        if(.not.if3d) write(*,255) 'u tau',utmin,utmax,utave
        if(iftl) write(*,255)'T_p+',tlmin,tlmax,tlave
        do ifld=1,ldimt-1
          if(ifpsp(ifld)) then
            write(pname,'(a14,i1)') "PS_p+ ",ifld 
            write(*,255) pname,spmin(ifld),spmax(ifld),spave(ifld)
          endif
        enddo
        write(*,*)
      endif

 255  format(a15,5es13.4)

      return
      end

c-----------------------------------------------------------------------
      subroutine backpts(i0,i1,j0,j1,k0,k1,isd)
        implicit none
        include 'SIZE'

        integer i0,i1,j0,j1,k0,k1,isd

        i0=1
        j0=1
        k0=1
        i1=nx1
        j1=ny1
        k1=nz1
        if(isd.eq.1) then
          j0=2
          j1=2
        elseif(isd.eq.2) then
          i0=nx1-1
          i1=nx1-1
        elseif(isd.eq.3) then
          j0=ny1-1
          j1=ny1-1
        elseif(isd.eq.4) then
          i0=2
          i1=2
        elseif(isd.eq.5) then
          k0=2
          k1=2
        elseif(isd.eq.6) then
          k0=nz1-1
          k1=nz1-1
        endif

        return
        end
c-----------------------------------------------------------------------
