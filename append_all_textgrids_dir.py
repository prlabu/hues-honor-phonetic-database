import textgrids
import sys
import glob, os
from praatio import tgio
import librosa



textGrid_dir = sys.argv[1]
wavfile_dir = sys.argv[2]

interview_num = textGrid_dir.split('_')[1]

fout = f'{sys.argv[3]}/{interview_num}.TextGrid'

tg = None
sound_len = librosa.get_duration(filename=f'{wavfile_dir}/{interview_num}.wav')

print(textGrid_dir)
files = glob.glob(f"{textGrid_dir}/*.textGrid")
sorted_files = sorted(files, key=lambda s: int(s.split('-')[1])) 
for file in sorted_files:
    print(file)
    if not tg:
        tg = tgio.openTextgrid(file)
        continue
    
    new_tg = tgio.openTextgrid(file)
    tg = tg.appendTextgrid(new_tg)

tg.save(fout, maxTimestamp=sound_len, useShortForm=False)




