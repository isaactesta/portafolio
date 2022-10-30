function periods = period_detection_findpeaks(autocor,lags,fs,fig_handle)
% Manolis Christodoulakis @ 2014
    
    MinPeakHeight = 0.001;
%     Threshold = 0;
    [pk,lc] = findpeaks(autocor,'MinPeakDistance',fs);%,'Threshold',Threshold);%,'MinPeakheight',MinPeakHeight);
    difflc = diff(lc);
    display('Distances between neighboring peaks (hours)');
    difflc/fs
    period  = mean(difflc)/fs;
    fprintf('Period using mean  : %f\n',period);
    median_period = median(difflc)/fs;
    fprintf('Period using median: %f\n',median_period);
    periods = period;
    pks = {pk};
    lcs = {lc};
    [Rmax lambda r_out outlier outlier_num] = gesd(difflc, strread(num2str((1:numel(lc)-1)),'%s'), ceil(0.25*numel(lc)));
    if ~isempty(outlier_num)
        display('Outliers found:');
        difflc(outlier_num(:,1))/fs
        difflc(outlier_num(:,1)) = [];
        new_period = mean(difflc)/fs;
        fprintf('Period using mean after removing outliers: %f\n',new_period);
    end
    display('---------------------')
    
    while ~isempty(period)
        [pk,lc] = findpeaks(autocor,'MinPeakDistance',ceil(period)*fs);%,'MinPeakheight',MinPeakHeight);
        if size(lc,1)>1
%             % Keep only prominent peaks
%             [max_pk_value,max_pk_loc] = max(pk);
%             prominent_indx = find(pk>max_pk_value/3);
%             pk = pk(prominent_indx);
%             lc = lc(prominent_indx);
            
            difflc = diff(lc);
            display('Distances between neighboring peaks');
            difflc/fs
            period = mean(difflc)/fs;
            fprintf('Period using mean  : %f\n',period);
            median_period = median(difflc)/fs;
            fprintf('Period using median: %f\n',median_period);
            
            fprintf('Relative Std       : %f\n',std(difflc)/(period*fs));
            [Rmax lambda r_out outlier outlier_num] = gesd(difflc, strread(num2str((1:numel(lc)-1)),'%s'), ceil(0.25*numel(lc)));
            if ~isempty(outlier_num)
                display('Outliers found:');
                difflc(outlier_num(:,1))/fs
                difflc(outlier_num(:,1)) = [];
                new_period = mean(difflc)/fs;
                fprintf('Period using mean after removing outliers: %f\n',new_period);
            end
            
%             % Get rid of large jumps
%             sorted = sort(difflc);
%             diff_sorted = diff(sorted);
%             [~,pos] = max(diff_sorted) 
%             if ~isempty(pos) && (pos>1 && pos+1>size(period,1)/2) && (diff_sorted(pos)>2*max(diff_sorted(1:pos-1)))
%                                 %&& sorted(pos+1)>1.4*median(sorted(1:pos))
%                 period = mean(difflc(difflc<sorted(pos+1)))/fs;
%                 fprintf('Jump detected: from %d to %d\n',sorted(pos),sorted(pos+1))
%                 fprintf('New period: %f\n',period);
%             end
            display('---------------------')
            
            if period<26 %&& ~isempty(pos)
                periods(end+1,1) = period;
                pks{1,end+1} = pk;
                lcs{1,end+1} = lc;
            else
                period = [];
            end
        else
            period = [];
        end
    end
    
    if nargin<4
        figure; plot(lags/fs,autocor);
    else
        subplot(fig_handle);
    end
    
    hold on
    N = size(periods,1);
    Legends = cell(N+1,1);  
    Legends{1} = '';
    Styles = {'or','vk','+y','>b','<m','*r','xk','.y','sb','dm'};
    for i=1:N
        plot(lags(lcs{1,i})/fs,pks{1,i}+i*0.05,Styles{1,mod(i,size(Styles,2))+1});
        Legends{i+1} = ['Period: ' num2str(periods(i))];
    end
    hold off
    legend(Legends)
    xlabel('Time (hours)');
    set(findall(gcf,'type','text'),'fontSize',24);
    set(findall(gcf,'type','axes'),'fontsize',14);
    
end