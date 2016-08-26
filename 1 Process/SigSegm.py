from matplotlib.pyplot import figure, show
from numpy import pi, sin, linspace, array, mean, std, where, diff, sign, histogram
from scipy.interpolate import interp1d
import ast, sqlite3, math, os

#Globals
FREQ = 50 #want 50Hz sampling
SEG_LEN = 5 * FREQ #5 sec segments
SEG_DIST = 2.5 #2.5 sec between seg starts
global RATE
time, colx, coly, colz = [],[],[],[]

#Get the file name
filename = input("Filename: ")
conn = sqlite3.connect(filename)
raw_cursor = conn.cursor()

def init_signal(curse):
    start = 0
    data = curse.execute('select id,timestamp,x,y,z from accel_data')
    #skip the header
    next(data)
    #fill in the X Y Z vectors
    for row in data:
        if start == 0:
            start = (float(float(row[1])))/1000000000 #divide to get nano-secs
        time.append(((float(float(row[1])))-start)/1000000000)
        colx.append(float(float(row[2])))
        coly.append(float(float(row[3])))
        colz.append(float(float(row[4])))
    print("Raw data loaded...")

def interp_signal():    
    #Set up an interval from time[0] to time[-1] with RATE samples
    period = time[-1]-time[0]
    print("Sampled Freq: ", len(time)/period)
    RATE = 50*period
    print("Total Length:",period,"seconds")
    freq = RATE/(period)
    print("Sampled to:",freq,"Hz")
    #return cubic interpolated signal
    return linspace(time[0],time[-1],RATE),interp1d(time,colx,kind='cubic'),interp1d(time,coly,kind='cubic'),interp1d(time,colz,kind='cubic')

#****************************************
#Obsolete
def normalize_signal(num, xi,yi,zi):
    #normalize by the mean accl
    x_mu = 0
    y_mu = 0
    z_mu = 0
    for i in range(num):
        for acclx in xi[i]:
            x_mu += acclx
        x_mu = x_mu/len(xi[i])
        xnorm = [x - x_mu for x in xi[i]]
        xi[i] = xnorm
            
        for accly in yi[i]:
            y_mu += accly
        y_mu = y_mu/len(yi[i])
        ynorm = [y - y_mu for y in yi[i]]
        yi[i] = ynorm

        for acclz in zi[i]:
            z_mu += acclz
        z_mu = z_mu/len(zi[i])
        znorm = [z - z_mu for z in zi[i]]
        zi[i] = znorm
    print("Normalized signal...")
    return xi,yi,zi
#*************************************

def segment_signal(x,y,z):
    #Segment data
    seg_num = int((len(x) / (SEG_LEN/2))-1) #number of segs from original sig
    idx = 0
    segm_x = []
    segm_y = []
    segm_z = []
    #for each segment
    for q in range(seg_num):
        newseg_x = []
        newseg_y = []
        newseg_z = []
        for i in range(idx, idx+(int(SEG_LEN))) :
            newseg_x.append(x[i])
            newseg_y.append(y[i])
            newseg_z.append(z[i])
        segm_x.append(newseg_x)
        segm_y.append(newseg_y)
        segm_z.append(newseg_z)
        idx = idx + int(SEG_DIST*FREQ)
    print("Signal segmented...")
    return seg_num,array(segm_x),array(segm_y),array(segm_z)

#**********************************************
#Obsolete
def extract_features(seg_num,segx, segy, segz):
    #Extract Features
    for r in range(seg_num):
        print("Means:")
        print(mean(segx[r]))
        print(mean(segy[r]))
        print(mean(segz[r]))
        print("Minimums:")
        print(min(segx[r]))
        print(min(segy[r]))
        print(min(segz[r]))
        print("Maximums:")
        print(max(segx[r]))
        print(max(segy[r]))
        print(max(segz[r]))
        print("Mean Abs Diff:")
        diffx = diff(segx[r])
        print(sum(diffx)/len(diffx))
        diffy = diff(segy[r])
        print(sum(diffy)/len(diffy))
        diffz = diff(segz[r])
        print(sum(diffz)/len(diffz))
        print("Standard Deviation:")
        print(std(segx[r]))
        print(std(segy[r]))
        print(std(segz[r]))
        print("Root Mean Square")
        sqrx = [a**2 for a in segx[r]]
        print(math.sqrt(sum(sqrx)/len(sqrx)))
        sqry = [a**2 for a in segy[r]]
        print(math.sqrt(sum(sqry)/len(sqry)))
        sqrz = [a**2 for a in segz[r]]
        print(math.sqrt(sum(sqrz)/len(sqrz)))
        print("Binned Distibution")
        histx, _ = histogram(segx[r], bins=len(segx[r]))
        print(histx)
        histy, _ = histogram(segy[r], bins=len(segy[r]))
        print(histy)
        histz, _ = histogram(segz[r], bins=len(segz[r]))
        print(histz)
        print("Zero Crossings:")
        xcrossz = 0
        for k in range(len(segx[r])-1):
            if segx[r][k] > 0 and segx[r][k+1] < 0:
                xcrossz = xcrossz + 1
        print(xcrossz)
        ycrossz = 0
        for k in range(len(segy[r])-1):
            if segy[r][k] > 0 and segy[r][k+1] < 0:
                ycrossz = ycrossz + 1
        print(ycrossz)
        zcrossz = 0
        for k in range(len(segz[r])-1):
            if segz[r][k] > 0 and segz[r][k+1] < 0:
                zcrossz = zcrossz + 1
        print(zcrossz)
#******************************************************
        
def plot_signal(num,f,normx, normy, normz,xi,yi,zi):
    #Plot the signal for visual verification of data
    time[:] = [x - time[0] for x in time]
    f[:] = [y - f[0] for y in f]
    fig = figure()
    ax = fig.add_subplot(311)
    ax.set_ylabel('X Accel')
    ax.plot(time,colx,'ro')#,f,xi(f),'go')
    for a in range(num):
        if a == 0: ax.plot(f[0:(SEG_LEN*a)+SEG_LEN],normx[a],'-b.')
        else:
            ax.plot(f[((SEG_LEN/2)*a):((SEG_LEN/2)*a)+SEG_LEN],normx[a],'-b.')
    ay = fig.add_subplot(312)
    ay.set_ylabel('Y Accel')
    ay.plot(time,coly,'ro')#,f,yi(f),'go')
    for b in range(num):
        if b == 0: ay.plot(f[0:(SEG_LEN*b)+SEG_LEN],normy[b],'-b.')
        else:
            ay.plot(f[((SEG_LEN/2)*b):((SEG_LEN/2)*b)+SEG_LEN],normy[b],'-b.')
    az = fig.add_subplot(313)
    az.set_ylabel('Z Accel')
    az.set_xlabel('Seconds')
    az.plot(time,colz,'ro')#,f,zi(f),'go')
    for c in range(num):
        if c == 0: az.plot(f[0:(SEG_LEN*c)+SEG_LEN],normz[c],'-b.')
        else:
            az.plot(f[((SEG_LEN/2)*c):((SEG_LEN/2)*c)+SEG_LEN],normz[c],'-b.')
    show()

def write_csv(segnums,xseg,yseg,zseg):
    #Write the segments out to individual files
    print("Writing to files...")
    out_file = os.path.splitext(filename)[0]
    os.mkdir(out_file)
    for i in range(segnums):
        count = ""
        count = str(i)
        new_file = out_file + '\\' + count + '.csv'
        f = open(new_file, 'w')
        for j in range(len(xseg[i])):
            f.write(str(xseg[i][j])+","+str(yseg[i][j])+","+str(zseg[i][j]))
            f.write("\n")
        f.close()

#Main function calls
init_signal(raw_cursor)
fi,xi,yi,zi = interp_signal()
num,xseg,yseg,zseg = segment_signal(xi(fi),yi(fi),zi(fi))
#xn,yn,zn = normalize_signal(num,xseg,yseg,zseg) #Obsolete
#extract_features(num,xseg,yseg,zseg) #Obsolete
write_csv(num,xseg,yseg,zseg)
plot_signal(num,fi,xseg,yseg,zseg,xi,yi,zi)


