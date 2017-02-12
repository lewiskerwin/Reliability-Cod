function lk_waveformplot(data,cfg,iTI,ireg,isub,icond)

clear timeidx

span=10;
timerange = 1:300;
timeidx = find(data.times(:,1,1)==timerange(1)):find(data.times(:,1,1)==timerange(end));
%Note: time idx currently does not include zero 
trialmax=iTI*10;
fewtrials =5;
figure
clear splitrange trialstoplot latencytoplot AUCtoplot legendnames   


%WEIRDLY THE CODE BELOW SELECTS TRIALS FROM A VARIABLE WITHOUT SPECIFYING
%WHICH DAY. I DON'T KNOW HOW THIS DOESN'T GIVE IT AN ERROR. AND EXTRA
%WEIRDLY IT WORKS OUT TO LINE UP WITH AMPLAT.COND.MEAN AND
%AMPMAX.COND.MEAN.  WHAT IS DOES IS SELCT ONLY FROM DAY 1, BUT THIS WOULD
%GIVE A WAVEFORM THAT WOULD BE DIFFERENT THAN THE LATENCIES CALCULATED IN
%HALFSAMPLETP, WHICH WOULD USE BOTH DAYS I THINK... WEIRD.

figcnt=1;
%1. PLOT TRIALS
cnt=1;
for itrial=1:trialmax
   %splitrange = ((isplit-1)*iTI*cfg.trialincr/cfg.numsplit)+1:isplit*iTI*cfg.trialincr/cfg.numsplit;
   trialstoplot(:,cnt) = mean(mean(data.amp(cfg.regs(ireg).chan,timeidx,itrial,icond,isub),1),3);
    cnt=cnt+1;
end
subplot(4,1,figcnt)
plot(timerange,trialstoplot(:,1:trialmax),'LineWidth',2);
hold on;
ylim=get(gca,'ylim');
xlim = get(gca,'xlim');
axis([-50,xlim(2),ylim(1),ylim(2)]);
plot([0 0],[ylim(2) ylim(1)],'k-.')
text(-10,(ylim(2)-(ylim(2)-ylim(1))/10),'Pulse','FontWeight','Bold');
%title('Load Individual Trials (for a given region of interest)');
figcnt=figcnt+1;
box off; xticklabels('off'); ylabel('uV'); hold off;

%2. PLOT AVG (OF ALL TRIALS)
trialavg = mean(trialstoplot,2);
subplot(4,1,figcnt)
plot (timerange, trialavg,'LineWidth',2)
hold on
ylim=get(gca,'ylim');
xlim = get(gca,'xlim');
axis([-50,xlim(2),ylim(1),ylim(2)]);
plot([0 0],[ylim(2) ylim(1)],'k-.')
text(-10,(ylim(2)-(ylim(2)-ylim(1))/10),'Pulse','FontWeight','Bold');
figcnt=figcnt+1;
%title('Take the Average Waveform');
box off;xticklabels('off'); ylabel('uV'); hold off


%3. SMOOTH AND ABS
smoothed = abs(smooth(trialavg,5));
subplot(4,1,figcnt)
plot (timerange, smoothed,'LineWidth',2);
%title('Smooth and Rectify Average to Find Peaks in Windows of Interest');
hold on
%Show Pulse
ylim=get(gca,'ylim');
xlim = get(gca,'xlim');
axis([-50,xlim(2),ylim(1),ylim(2)]);
plot([0 0],[ylim(2) ylim(1)],'k-.')
text(-10,(ylim(2)-(ylim(2)-ylim(1))/10),'Pulse','FontWeight','Bold');
%FIND LAT and AMP
peaklat = data.amplat.cond.mean(ireg,:,icond,isub,iTI);
peakamp = data.ampmax.cond.mean(ireg,:,icond,isub,iTI);
plot([peaklat' peaklat']',[zeros(cfg.wndwnumber,1) peakamp']','k--');
plot([zeros(cfg.wndwnumber,1)-50 peaklat']',[peakamp' peakamp']','k--');
aucidx = peaklat +1 - data.times(1,icond,isub);
plot ( peaklat, smoothed(round(peaklat,0)),'o')
%plot (peaklat,peakamp,'o');
%plot (peaklat, trialavg(round(peaklat,0)),'o')
hold off;
box off;xticklabels('off'); ylabel('|uV|');
figcnt=figcnt+1;


%4. PLOT AVG AGAIN WITH AUC
trialavg = mean(trialstoplot,2);
subplot(4,1,figcnt)
plot (timerange, trialavg,'LineWidth',2)
hold on
%Show pulse
ylim=get(gca,'ylim');
xlim = get(gca,'xlim');
axis([-50,xlim(2),ylim(1),ylim(2)]);
plot([0 0],[ylim(2) ylim(1)],'k-.')
text(-10,(ylim(2)-(ylim(2)-ylim(1))/10),'Pulse','FontWeight','Bold');
%Show Integration
for iwndw = 1:cfg.wndwnumber
    peakrange =  data.amplat.cond.mean(ireg,iwndw,isub,iTI) - cfg.peak.width(iwndw) : data.amplat.cond.mean(ireg,iwndw,isub,iTI) + cfg.peak.width(iwndw);
    plot([peakrange(1) peakrange(1)],ylim,[peakrange(end) peakrange(end) ],ylim,'Color',[1 0 0]);
    plot([peaklat(iwndw) peaklat(iwndw)],[ylim(2) 0],'k--')
    area(peakrange,trialavg(peakrange)) 
end
hold off;
figcnt=figcnt+1;
%title('Integrate Area Under Curve for Avg Waveform');
box off;xlabel('ms'); ylabel('uV');

%APPLY COREY'S FUNCTION

Date = datestr(today('datetime'));
fname = [cfg.ProjectName '_Wave_Reg' num2str(ireg) 'Sub' num2str(isub) 'TI' num2str(iTI) '_' Date];
cd(cfg.stabilityresults);
ckSTIM_saveFig(fname,10,10,300,'',4,[10 8]);



end