function figs_to_grid(figs,nrows,ncols,row_titles,col_titles,legends,output)
% Similar to figs_to_subplot, only now titles go above columns and to the
% left of the rows
% *** NOT FINISHED!!

% Read data from the figs
m = nrows;
n = ncols;
h = zeros(m*n,1);
fig = [];
for i=1:m*n
    if ~exist(figs{i}, 'file')
        error([figs{i} ' does not exist']);
    end
    
    FileInfo = dir(figs{i}); TimeStamp = FileInfo.date
    h(i)  = open(figs{i});
    title('');
    %fig(:,i) = get(gca,'children'); %get handle to all the children in the figure
    padadd(fig,get(gca,'children'));
end

% Create new figure
newh = figure;
%set(newh, 'Position', [1900 1500 1000 1100])
s  = zeros(m*n,1);  % Reserve first row for legend
for i=1:m
    h1 = text(-0.25, 0.5,row_titles{i});
    set(h1, 'rotation', 90)
    for j=1:n
        if i==1
            text(0.35,1.2,col_titles{j});
        end
        s(i) = subplot(nrows,ncols,(i-1)*ncols+j);
        %title(titles{i});
        copyobj(fig(:,i),s(i)); %copy children to new parent axes i.e. the subplot axes
        if size(legends,1)==1 && i==1
            leg = legend(legends);
            set(leg,'FontSize',4);
        elseif size(legends,1)~=1
            leg = legend(legends(i,:));
            set(leg,'FontSize',4);
        end
    end
end


% Save to output file
saveas(newh,[output '.jpg']);
saveas(newh,[output '.fig']);

end