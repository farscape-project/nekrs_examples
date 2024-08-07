C-----------------------------------------------------------------------
      subroutine y_p_limitsRS(wd,ifexport)
      implicit none
      include 'SIZE'
      include 'TOTAL'
C
C     NOTE: min value should work if domain has internal corners
C
      logical ifexport
      logical ifdef,ifut,iftl,ifpsp(ldimt-1)
      common /y_p_print/ ifut,iftl,ifpsp

      character*15 pname
      integer e,i,i0,i1,j,j0,j1,k,k0,k1,ib,jb,kb,i2,j2
      integer isd,ifld,ntot
c     integer estrd,ipt,wpt
      real gradu(lx1,ly1,lz1,3,3),wd(lx1,ly1,lz1,lelv)
      real ypf(lx1,ly1,lz1,lelv),dist
      real tau(3),norm(3),vsca,tauw
      real utau,rho,mu,yp
      real ypmin,ypmax,ypave,vol
      real glmin,glmax,glsum
      real tsv(lx1*ly1*lz1*lelt)
      logical ifgrad

      ypmin=1.0e10
      ypmax=-1.0e10
      ypave=0.0
      vol=0.0

      ntot = nx1*ny1*nz1*nelv
      call rzero(ypf,ntot)

      mu=cpfld(1,1)
      rho=cpfld(1,2)

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
            call facind(i0,i1,j0,j1,k0,k1,lx1,ly1,lz1,isd)
            do k=k0,k1
            do j=j0,j1
            do i=i0,i1
              ib=i
              jb=j
              kb=k
              if    (isd.eq.1) then
                jb=2
              elseif(isd.eq.2) then
                ib=lx1-1
              elseif(isd.eq.3) then
                jb=ly1-1
              elseif(isd.eq.4) then
                ib=2
              elseif(isd.eq.5) then
                kb=2
              else
                kb=lz1-1
              endif
              dist=wd(ib,jb,kb,e)
              if(dist.gt.1.0e-12) then
                call getSnormal(norm,i,j,k,isd,e)

                do i2=1,ldim
                tau(i2)=0.0
                  do j2=1,ldim
                    tau(i2)=tau(i2)+mu*norm(j2)*
     &                           (gradu(i,j,k,i2,j2)+gradu(i,j,k,j2,i2))
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
                yp=dist*utau*rho/mu
                ypf(i,j,k,e) = yp
                ypmin=min(ypmin,yp)
                ypmax=max(ypmax,yp)
                ypave=ypave+yp*bm1(i,j,k,e)
                vol=vol+bm1(i,j,k,e)
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

      if(nio.eq.0)then
        write(*,255) 'y_p+',ypmin,ypmax,ypave
        write(*,*)
      endif

      if(ifexport) then
        call save_ioflags
        call clear_ioflags

        call copy(tsv,t,ntot)
        call copy(t,ypf,ntot)

        ifxyo=.true.
        ifto =.true.

        call prepost(.true.,'ypf')

        call copy(t,tsv,ntot)
        call restore_ioflags
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
      subroutine save_ioflags

      implicit none

      include 'SIZE'
      include 'INPUT'

      logical ifbackup(0:ldimt+4)
      integer i

      common /ioflagss/ ifbackup

      ifbackup(0)=ifxyo
      ifbackup(1)=ifvo
      ifbackup(2)=ifpo
      ifbackup(3)=ifto
      do i = 1,ldimt1
        ifbackup(3+i)=ifpsco(i)
      enddo

      return
      end
c-----------------------------------------------------------------------
      subroutine restore_ioflags

      implicit none

      include 'SIZE'
      include 'INPUT'

      logical ifbackup(0:ldimt+4)
      integer i

      common /ioflagss/ ifbackup

      ifxyo=ifbackup(0)
      ifvo =ifbackup(1)
      ifpo =ifbackup(2)
      ifto =ifbackup(3)
      do i = 1,ldimt1
        ifpsco(i)=ifbackup(3+i)
      enddo

      return
      end
c-----------------------------------------------------------------------

      subroutine clear_ioflags

      implicit none

      include 'SIZE'
      include 'INPUT'

      integer i

      ifxyo=.false.
      ifvo =.false.
      ifpo =.false.
      ifto =.false.
      do i = 1,ldimt1
        ifpsco(i)=.false.
      enddo

      return
      end
c-----------------------------------------------------------------------
