function figs_to_subplots(figs,titles,rows,cols,legends,output)

% Read data from the figs
n  = size(figs,1);
h  = zeros(n,1);
for i=1:n
    if ~exist(figs{i}, 'file')
        error([figs{i} ' does not exist']);
    end
    
    FileInfo = dir(figs{i}); TimeStamp = FileInfo.date
    h(i)  = open(figs{i});
    title('');
    fig(:,i) = get(gca,'children'); %get handle to all the children in the figure
end

% Create new figure
newh = figure;
% hp = get(h(1),'position');
% ratio = hp(4)/hp(3);
% newhp = get(newh,'position');
% newhp(4) = (newhp(3)/cols)*ratio*rows*0.7; 
% set(newh, 'Position', newhp)
s  = zeros(n,1);  % Reserve first row for legend
for i=1:n
    s(i) = subplot(rows,cols,i);
    
    % resize to same ratio height:width as the figure
%     hp = get(h(i),'position');
%     ratio = hp(4)/hp(3);
%     sp = get(s(i),'position');
%     sp(4) = sp(3)*ratio; 
%     set(s(i), 'position', sp);
    
    % set the titles
    title(titles{i});
    if ceil(i/cols)==rows
        xlabel('Time (sec)');
    end
    
    % add the figure itself
    copyobj(fig(:,i),s(i)); %copy children to new parent axes i.e. the subplot axes
    
    % add the legend (only once, unless multiple legends are provided)
    if size(legends,1)==1 && i==1
        leg = legend(legends);
        set(leg,'FontSize',4);
    elseif size(legends,1)~=1
        leg = legend(legends(i,:));
        set(leg,'FontSize',4);
    end
end

% Add legend at first subplot
% s(1) = subplot(rows+1,cols,1:cols)
% pos = get(s(1),'position')
% leg = legend(s(1),['Bipolar montage';'Common reference montage';'Average reference montage'])
% set(leg,'position',pos);
% axis(s(1),'off');


% Optionally, add a central title
% ha = axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off',...
%           'Visible','off','Units','normalized','clipping','off');
% text(0.5, 1,'Average degree','HorizontalAlignment','center',...
%     'VerticalAlignment', 'top');

% Save to output file
saveas(newh,[output '.jpg']);
saveas(newh,[output '.fig']);

end