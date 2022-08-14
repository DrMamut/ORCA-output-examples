import os
import datetime as dt
import fnmatch

today = dt.datetime.now().date()
print('''
    List of submitted files:
    ''')

for file in os.listdir('.'):
    if fnmatch.fnmatch(file, '*.sh'):
        filetime = dt.datetime.fromtimestamp(os.path.getctime('' + file))       
        if filetime.date() == today:
            os.system(('sbatch {} &').format(file))
            print(file, filetime)
            #print(file, filetime)
     
os.system('''

''') 
os.system('''

''')   
os.system('squeue -u domller ')
print('')
exit()