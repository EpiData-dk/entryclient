#!/bin/bash
# Compile all versions!

###########################################
#  DO NOT EDIT			          #
###########################################
LOCALIZATIONS_FILE="buildall.rc"
. "$LOCALIZATIONS_FILE"

get_filename() {
  FILENAME="$PROGRAMNAME.$PROGRAM_VERSION.$MY_CPU_TARGET-$MY_OS_TARGET"
  if [ $MY_LCL_TARGET = "win32" ]
  then
    FILENAME="$FILENAME.exe"
    ln -sf "$FILENAME" "$PROGRAMNAME.$MY_OS_TARGET.exe"
  fi
}

compile() {
  echo "Compiling for: $MY_CPU_TARGET-$MY_OS_TARGET ($MY_LCL_TARGET)"
  echo "------------------------------"
  get_filename

#  echo "make clean release CPU_TARGET=$MY_CPU_TARGET OS_TARGET=$MY_OS_TARGET > /dev/null"
  make clean release CPU_TARGET=$MY_CPU_TARGET OS_TARGET=$MY_OS_TARGET > /dev/null
  if [ $MY_LCL_TARGET = "win32" ]
  then
    OUTPUTFN=$PROGRAMNAME.exe
  else
    OUTPUTFN=$PROGRAMNAME
  fi
 
  if [ -a $OUTPUTFN ]
  then
    mv -f $OUTPUTFN $FILENAME

    ZIP_NAME=$PROGRAMNAME.$PROGRAM_VERSION
    echo "$ZIP_NAME"
    case $MY_LCL_TARGET in
      win32)
        case $MY_OS_TARGET in
          win32)
            POSTFIX="win.32"
             ;;
          win64)
            POSTFIX="win.64"
             ;;
        esac
        FINALZIP_NAME=$ZIP_NAME.$POSTFIX.zip
        zip $FINALZIP_NAME $FILENAME
      	 ;;
      gtk2)
        case $MY_CPU_TARGET in
          x86_64)
            POSTFIX="linux.64"
            ;;
          i386)
            POSTFIX="linux.32"
            ;;
        esac
        FINALZIP_NAME=$ZIP_NAME.$POSTFIX.tgz
        tar -zcf $FINALZIP_NAME $FILENAME
           ;;
      carbon)
        strip $FILENAME
        case $MY_CPU_TARGET in
          powerpc)
            POSTFIX="powerpc"
            ;;
          i386)
            POSTFIX="intel"
            ;;
        esac
	ln -sf $FILENAME $OUTPUTFN
        FINALZIP_NAME=$ZIP_NAME.mac.$POSTFIX.zip
        zip -r -9 $FINALZIP_NAME "$PROGRAMNAME.app"
        ;;
      *)
       ;;
    esac
    mv $FINALZIP_NAME "$HOME/epiexec/"		
  else
    echo "Error in compilation!"
    return
  fi

  echo ""
}

get_version_info() {
  V1=`cat $PROGRAMNAME.lpi | grep MajorVersionNr | cut -c 30-30`
  if [ -z $V1 ]
  then
    V1="0"
  fi

  V2=`cat $PROGRAMNAME.lpi | grep MinorVersionNr | cut -c 30-30`
  if [ -z $V2 ]
  then
    V2="0"
  fi

  V3=`cat $PROGRAMNAME.lpi | grep RevisionNr | cut -c 26-26`
  if [ -z $V3 ]
  then
    V3="0"
  fi

  V4=`cat $PROGRAMNAME.lpi | grep BuildNr | cut -c 23-23`
  if [ -z $V4 ]
  then
    V4="0"
  fi

  PROGRAM_VERSION="$V1.$V2.$V3.$V4"
}
get_version_info

echo "**********************************"
echo " Start compiling... ($PROGRAMNAME)"
echo " Version: $PROGRAM_VERSION"
echo "**********************************"

for TARGET in $ALL_TARGETS ; do {
  MY_CPU_TARGET=`echo "$TARGET" | cut -f 1-1 -d '-'`
  MY_OS_TARGET=`echo $TARGET | cut -f 2-2 -d '-'`
  MY_LCL_TARGET=`echo $TARGET | cut -f 3-3 -d '-'`
  compile
} ; done

echo "**********************"
echo "        DONE!"
echo "**********************"

