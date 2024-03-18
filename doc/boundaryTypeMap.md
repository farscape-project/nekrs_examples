# Options for `boundaryTypeMap`

Various keys can be passed to the `boundaryTypeMap` variable in `.par`, some of which are equivalent and some of which require additional coding in `.oudf` to provide a value. Note that in the .par file, strings that are not provided in quotes are read as all lower case (so e.g. `I` is equivalent to `i`).

## Vector (velocity) BCs:
| Text key | Equivalent keys | .oudf function name | ID |
| --- | --- | --- | --- |
| `periodic` | `p` |  | `0` |
| `zerovalue` | `wall`, `w` |  | `bcMap::bcTypeW` |
| `interpolation` | `int` |  | `bcMap::bcTypeINT` |
| `codedfixedvalue` | `inlet`, `codedfixedvalue+moving`, `v`, `mv` | `velocityDirichletConditions` | `bcMap::bcTypeV` |
| `zeroxvalue/zerogradient` | `slipx`, `symx` |  | `bcMap::bcTypeSYMX` |
| `zeroyvalue/zerogradient` | `slipy`, `symy` |  | `bcMap::bcTypeSYMY` |
| `zerozvalue/zerogradient` | `slipz`, `symz` |  | `bcMap::bcTypeSYMZ` |
| `zeronvalue/zerogradient` | `sym` |  | `bcMap::bcTypeSYM` |
| `zeroxvalue/codedfixedgradient` | `tractionx`, `shlx` |  | `bcMap::bcTypeSHLX` |
| `zeroyvalue/codedfixedgradient` | `tractiony`, `shly` |  | `bcMap::bcTypeSHLY` |
| `zerozvalue/codedfixedgradient` | `tractionz`, `shlz` |  | `bcMap::bcTypeSHLZ` |
| `zeronvalue/codedfixedgradient` | `shl` |  | `bcMap::bcTypeSHL` |
| `zeroyzvalue/fixedgradient` | `onx` |  | `bcMap::bcTypeONX` |
| `zeroxzvalue/fixedgradient` | `ony` |  | `bcMap::bcTypeONY` |
| `zeroxyvalue/fixedgradient` | `onz` |  | `bcMap::bcTypeONZ` |
| `fixedgradient` | `outlet`, `outflow`, `zerogradient`, `o` | `pressureDirichletConditions` | `bcMap::bcTypeO` |
| `none` |  |  | `bcMap::bcTypeNone` |


## Scalar BCs:

| Text key | Equivalent keys | .oudf function name | ID |
| --- | --- | --- | --- |
| `periodic` | `p` |  | `0` |
| `interpolation` | `int` |  | `bcMap::bcTypeINTS` |
| `codedfixedvalue` | `inlet`, `t` | `scalarDirichletConditions` | `bcMap::bcTypeS` |
| `zerogradient` | `zeroflux`, `insulated`, `outflow`, `outlet`, `i`, `o` |  | `bcMap::bcTypeF0` |
| `codedfixedgradient` | `flux`, `codedFixedgradient`, `f` | `scalarNeumannConditions` | `bcMap::bcTypeF` |
| `none` |  |  | `bcMap::bcTypeNone` |

