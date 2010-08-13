#!/bin/bash

REVISIONCMD=`which svn2revisioninc`

if [ -z $REVISIONCMD ]
then
  echo "const RevisionStr = '';" > "./revision.inc"
  exit
fi

$REVISIONCMD "./"
