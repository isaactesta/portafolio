function first_axis = plot_EEG_data(data,scale,channels,samples,srate,montage,first_axis)
% Plots EEG times series (scrollable), in the range (samples) specified
    
    % =====================================================
    % === Set default values
    if (nargin<2 || isempty(scale))
        %scale = max(1,nchannels/6);
        scale = 1;
    end
    if (nargin<3 || isempty(channels))
        channels = 1:size(data,2);
    end
    nchannels = size(channels,2)
    if (nargin<4 || isempty(samples))
        samples = 1:size(data,1);
    end
    if (nargin<5 || isempty(srate))
        srate = 200;
    end
    if (nargin<6 || isempty(montage))
        montage = 'bipolar';
    end
    
    colour = true;
    
    window_size = 10*srate; % number of sec * srate
    annot = [];
    global ANNOT;
    
    % =====================================================
    % === Create the plot
    hfig = figure('CloseRequestFcn',@my_closereq,'Color','White');
    if colour
        cc = hsv(nchannels);  % Rotate colours
    else
        cc = zeros(nchannels,3);
    end
    
    % Calculate proportional height
    range = max(data) - min(data);
    sum_range = sum(range);
    height = 0.9*range/sum_range;
    %height = scale/(nchannels+3)
    for i=nchannels:-1:1
        %bottom = 0.05+(nchannels-i+1)*(0.85-height)/(nchannels);
        %middle = 0.05 + height/2+(nchannels-i+1)*height
        middle = 0.06 + sum(height(i+1:nchannels))+height(i)/2;%((0.9-height(i))/nchannels)*(nchannels-i+1);
        ax(i) = axes('Position', [0.10, middle-height(i)/2, 0.8, scale*height(i)],'Color','None');
  
        plot(samples,detrend(data(samples,channels(i)),'constant'),'color',cc(i,:))
        
        set(gca, 'LooseInset', get(gca,'TightInset'))

        % Set common scale to all subplots
        if nargin<7 && i==nchannels
            first_axis = axis;
            axis on
        else
            axis(first_axis);
        end
        
        if i~=nchannels, axis off, end;
        
        set(gca,'YTick',[],'Box','off','Clipping','off');
        set(get(gca,'YLabel'),'clipping','off')
        set(findall(gca, 'type', 'text'), 'visible', 'on')
        ylabel(get_chan_label(channels(i),montage,srate),'Rotation',0,'Color',cc(i,:),'fontsize',16)
    end

%     axis on
    set(gca,'Color','None')
    set(gcf,'Color','white')
    set(gca,'ycolor',get(gcf,'Color'))
    linkaxes(ax(1:nchannels),'x');
    pan xon
    xlim([samples(1) samples(min(window_size,end))])
    
    figPos = get(gcf, 'Position');
    

    % =====================================================
    % === Add slider and button
    
    % Add slider
    %uicontrol('Style', 'slider', 'Callback', @sliderCallback);
    slmin = samples(1)
    slmax = samples(end)
    hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[srate window_size]./(slmax-slmin),'Value',slmin,...
                'Position',[100 10 figPos(4) 20],'Callback', @sliderCallback);
    
    window_start = get(hsl, 'Value');
    function sliderCallback(hObject, evt)
        %fprintf('Slider value is: %d\n', get(hObject, 'Value') );
        window_start = get(hObject, 'Value');
        xlim([window_start window_start+window_size])
    end

    % Add menu to save events
    hpop = uicontrol('Style', 'popup',...
           'String', 'Seizure start|Seizure end|Sleep start|Sleep end|Stage 1|Stage 2|Stage 3|Stage 4|REM|Wakefulness',...
           'Position', [figPos(4)+100 10 100 20],...
           'Callback', @setmap);   
    annot_selected = get(hpop, 'Value');%'Seizure start';
    function setmap(hObj,event) 
        val = get(hObj,'Value');
        if val ==1
            annot_selected = 'Seizure start';
        elseif val == 2
            annot_selected = 'Seizure end';
        elseif val == 3
            annot_selected = 'Sleep start';
        elseif val == 4
            annot_selected = 'Sleep end';
        elseif val == 5
            annot_selected = 'Stage 1';
        elseif val == 6
            annot_selected = 'Stage 2';
        elseif val == 7
            annot_selected = 'Stage 3';
        elseif val == 8
            annot_selected = 'Stage 4';
        elseif val == 9
            annot_selected = 'REM';
        elseif val == 10
            annot_selected = 'Wakefulness';
        end
        ANNOT{end+1,1} = window_start;
        ANNOT{end,2} = annot_selected;
        annot{end+1,1} = window_start;
        annot{end,2} = annot_selected;

        %annot
        %hfig = get(hObj,'Parent');
        setappdata(hfig,'annot',annot);
        %fprintf('The value saved is: %d \t %s\n',annot{end,1}, annot{end,2} );        
    end

%     uicontrol('Style', 'pushbutton', 'String', 'Save Event',...
%         'Position', [figPos(4)*0.8+200 10 100 20],...
%         'Callback', @setevent); 
    

%     function setevent(hObj,event)
%         annot{end+1,1} = window_start;
%         annot{end,2} = annot_selected;
%         annot
%         %fprintf('The value saved is: %d \t %s\n',annot{end,1}, annot{end,2} );
%     end
% 
%     annot
    %annot = ANNOT
    
    function my_closereq(src,evnt)
    % User-defined close request function 
    % to display a question dialog box 
       selection = questdlg('Export annotations to global variable?',...
          'Close Request Function',...
          'Yes','No','Cancel','Cancel'); 
       switch selection, 
          case 'Yes',
              ANNOT = getappdata(hfig,'annot')
              delete(gcf)
          case 'No'
              delete(gcf)
           case 'Cancel'
       end
    end
end

function label = get_chan_label(i,montage,srate)
    if strcmp(montage,'ref') || strcmp(montage,'unipolar')
        channel_labels = {'Fp1';'F7';'T3';'T5';'O1';'F3';'C3';'P3';'Fz';...
                          'Pz';'F4';'C4';'P4';'Fp2';'F8';'T4';'T6';'O2'};
    elseif strcmp(montage,'xltek')
        channel_labels = {'AC1';'AC2';'Ref';'Fp1';'F7';'T3';'T5';'O1';...
                          'F3';'C3';'P3';'Fz';'Cz';...
                          'Pz';'F4';'C4';'P4';'Fp2';'F8';'T4';'T6';'O2'};
    elseif strcmp(montage,'bipolar')
        channel_labels = {'Fp1-F7';'F7-T3';'T3-T5';'T5-O1';'Fp2-F8';...
                          'F8-T4';'T4-T6';'T6-O2';'Fp1-F3';'F3-C3';...
                          'C3-P3';'P3-O1';'Fp2-F4';'F4-C4';'C4-P4';...
                          'P4-O2';'Fz-Cz';'Cz-Pz'; 'F8 - AC27';...
                          'AC27 - T5'; 'Fp2 - AC28'; 'AC28 - T6';...
                          'AC23 - AC1'; 'AC24 - AC2'; 'AC25 - AC26'};
    elseif strcmp(montage,'bipolar_sleep')
        channel_labels = {'C3-A2';'C4-A1';'O1-A2';'O2-A1';'LOC-A2';'ROC-A1'};
    end
    
    if (i>=1 && i<=numel(channel_labels))
        label = channel_labels{i};
    else
        label = int2str(i);
    end
end

function x = plot_EEG_data_DELETE(data,scale,channels,samples,srate,montage)
% Plots EEG times series (scrollable), in the range (samples) specified
    
    if (nargin<2)
        %scale = max(1,nchannels/6);
        scale = 1;
    end
    if (nargin<3)
        channels = 1:size(data,2)
    end
    nchannels = size(channels,2)
    if (nargin<4)
        samples = 1:size(data,1);
    end
    if (nargin<5)
        srate = 200;
    end
    if (nargin<6)
        montage = 'bipolar';
    end
    
    
    %figure
    cc=hsv(nchannels);  % Rotate colours
    
    plotdata = fliplr(data(samples,channels));
    temp = cumsum(max(plotdata(:,1:end-1))) + cumsum(abs(min(plotdata(:,2:end))))
    add  = repmat([0 temp],size(plotdata,1),1);
    size(add)
    plotdata = fliplr(plotdata + add);
    miny = scale*min(plotdata(:,end))
    maxy = scale*max(plotdata(:,1))
    
    
    %figure;
    plot(samples, scale*plotdata)
    
%     max_data = max(max(data(samples,channels)));
%     min_data = min(min(data(samples,channels)));
%     for i=1:nchannels
%         ax(i) = subplot(nchannels,1,i);
%         plot(samples,data(samples,channels(i)),'color',cc(i,:))
%         
%         sub_pos = get(gca,'position'); % get subplot axis position
%         sub_pos
%         %span = max(data(samples,channels(i))) - min(data(samples,channels(i)));
%         sub_pos = sub_pos.*[1 1 1 scale]% - [0 sub_pos(4)*(scale-1)/2 0 0]
%         set(gca,'position',sub_pos)  
%         set(gca, 'LooseInset', get(gca,'TightInset'))
%         %max_data = max(data(samples,channels(i)));
%         %min_data = min(data(samples,channels(i)));
%         set(gca,'YLim',[min_data max_data]);
% 
%         %axis tight
%         axis off
%         set(gca,'YTick',[],'Box','off','Clipping','off');
%         set(get(gca,'YLabel'),'clipping','off')
%         set(findall(gca, 'type', 'text'), 'visible', 'on')
%         ylabel(get_chan_label(channels(i),montage),'Rotation',0,'Color',cc(i,:),'fontsize',12)
%     end

    axis on
    %set(gca,'box','off')
    %set(gca,'Color','none')
    %set(gca, 'YTick', [])
    %set(gca,'ycolor',get(gcf,'Color'))
    set(gca,'YLim',[miny maxy]);
    %set(gca,'DataAspectRatio',[20 1 1])
    %linkaxes(ax(1:nchannels),'x');
    pan xon
    xlim([samples(1) samples(min(10*srate,end))])
    legend(get_chan_labels(channels,montage),'Location','NorthEastOutside')
    %[x y] = ginput
end

function labels = get_chan_labels(channels,montage)
    if strcmp(montage,'ref') || strcmp(montage,'unipolar')
        channel_labels = {'Fp1';'F7';'T3';'T5';'O1';'F3';'C3';'P3';'Fz';...
                          'Pz';'F4';'C4';'P4';'Fp2';'F8';'T4';'T6';'O2'};
    elseif strcmp(montage,'bipolar')
        channel_labels = {'Fp1-F7';'F7-T3';'T3-T5';'T5-O1';'Fp2-F8';...
                          'F8-T4';'T4-T6';'T6-O2';'Fp1-F3';'F3-C3';...
                          'C3-P3';'P3-O1';'Fp2-F4';'F4-C4';'C4-P4';...
                          'P4-O2';'Fz-Cz';'Cz-Pz'; 'F8 - AC27';...
                          'AC27 - T5'; 'Fp2 - AC28'; 'AC28 - T6';...
                          'AC23 - AC1'; 'AC24 - AC2'; 'AC25 - AC26'};
    end
    
    labels = num2cell(channels);
    for i=1:numel(channels)
        if (i>=1 && i<=numel(channel_labels))
            labels{i} = channel_labels{i};
        else
            labels{i} = int2str(channels(i));
        end
    end
end

