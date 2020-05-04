#!/bin/bash

interview=$1

data_dir=~/Documents/data/hues-honor

LOG_FILE=log/${interview}_runP2FA.out
exec > >(tee -a ${LOG_FILE} )
exec 2> >(tee -a ${LOG_FILE} >&2)

if [[ $# -ne 1 ]]; then
    echo "please specify input arg: interview number"
    exit 0
fi

tmp_dir=tmp_$interview
rm -rf $tmp_dir
mkdir $tmp_dir
cp $data_dir/rawTranscripts/$interview.txt $tmp_dir/remaining.txt

# regStr="(?s)(?<={0:${t1}:\d\d}).*(?={0:${t2}:\d\d})"
# ggrep -Pzo regStr $data_dir/rawTranscripts/128.txt > $tmp_dir.txt
# sed '/{.*}/q' $data_dir/rawTranscripts/128.txt > $tmp_dir.txt
# awk '{print $0 "-|" > "file" NR ".txt"}' RS='{'  $data_dir/rawTranscripts/128.txt
# awk -v RS='/{.*}/' '{ outfile = "output_file_" NR; print > outfile}' $data_dir/rawTranscripts/128.txt
# sed 's/{0:12.*}\([^{]*\){0:14.*}/\1/' $data_dir/rawTranscripts/128.txt

maxIters=50
iter=0
tStart=-2

# until [[  -s $tmp_dir/remaining.txt || iter>maxIters ]]
until [[ $iter -gt $maxIters || -z $(grep '[^[:space:]]' $tmp_dir/remaining.txt) ]]
do 
    echo 'new chunk:' $iter
    iter=$(($iter+1))

    tStart=$(($tStart+2))
    tEnd=$(($tStart+2))
    echo 'start: '$tStart ', end: '$tEnd
     
    csplit $tmp_dir/remaining.txt '/{.*}/'
    sed '1d' xx01 > $tmp_dir/remaining.txt
    cp $tmp_dir/remaining.txt $tmp_dir/remaining$tEnd.txt
    ./strip-transcript.sh xx00 $tmp_dir/$interview-$tStart-$tEnd.txt
    rm xx00 xx01

    ffmpeg -i $data_dir/WAV/$interview.wav -ar 11025 -ss 00:$tStart:00  -to 00:$tEnd:00 $tmp_dir/$interview-$tStart-$tEnd.wav

    python p2fa/align.py $tmp_dir/$interview-$tStart-$tEnd.wav $tmp_dir/$interview-$tStart-$tEnd.txt $tmp_dir/$interview-$tStart-$tEnd.textGrid
    # python3 p2fa_py3/p2fa/align.py $tmp_dir/129-0-2.wav $tmp_dir/xx00 $tmp_dir/128-0-2.textGrid
    # python p2fa/align.py $tmp_dir/128-0-2.wav xx00 $tmp_dir/128-0-2.textGrid
    
    wait

done

# append_all_textgrids_dir [textGrid dir] [WAV file dir] [out file dir]
python3 append_all_textgrids_dir.py $tmp_dir $data_dir/WAV $data_dir/textGrids-p2fa-out

