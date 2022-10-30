function [C,normalized_autocorrelation] = periodicity_netsw_netproperty(dir,mainfile,experiment, property,thresholds,nosave)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Initialize
    %
    patient_title     = patient_to_str_public(dir);
    property_title    = fname_to_str(property);
    x_axis_title_per  = 'Time lag (hours)';
    figdir            = [dir '/' mainfile '/' experiment ...
                         '/window=5/threshold=' num2str(thresholds(1))];
    
    if nargin<6, nosave = []; end
    
    % Load info
    load([dir '/' mainfile '.mat'],'srate','starttime','seizstart',...
                'seizend','sleepstart','sleepend','sleep_annot','gaps');
    if ~exist('sleep_annot','var') sleep_annot = []; end;
    
    % Load data
    load([dir '/' mainfile '/' experiment '/nets.mat'],'nets_w5');
    
    [~, ~, timemoments, networks] = size(nets_w5);
    x_axis_values_per = [-(timemoments-1)*5/3600:5/3600:(timemoments-1)*5/3600];

    for j=1:networks
        if (networks==1)
            net_filename = '';
            net_title = '';
        else
            net_filename = ['_' strrep(network_to_freq_str(j),' band','')];
            net_title = network_to_freq_str(j);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Calculate property of the network and its autcor.
        % 
        for tr = 1:size(thresholds,2)
            
            % Calculate the property of the network
            nets_bin = binarize(nets_w5,thresholds(tr));
            for t=1:timemoments
                C(t,tr) = feval(property,nets_bin(:,:,t,j));
            end
            
            % Smooth it
            C2(:,tr) = C(:,tr) - mean(C(:,tr),1);
            C3(:,tr) = remove_mean(C(:,tr),0.98);
            C3(:,tr) = C3(:,tr)';%+min(C3(:,tr));
            if min(C3(:,tr)) ~= 0
                fprintf('>>>> ATTENTION! <<<<< min(C3(:,tr)) = %f\n', min(C3(:,tr)));
            end
    %        C3a = C3 - mean(C3,2);
    
            % Normalized autocorrelation
            autocorrelation = xcorr(C2(:,tr), 'unbiased');
            display('Done autocorrelating...');
            normalized_autocorrelation(:,tr) = autocorrelation./autocorrelation(timemoments);
            display('Done normalizing...');
        end
        
        if exist('gaps','var')
            gaps
            window_gaps = ceil(gaps/(5*srate))
            window_gaps/720
            ngaps = size(gaps,1)
            for i=1:ngaps
                C3(window_gaps(i,1):window_gaps(i,2)) = NaN;
                C(window_gaps(i,1):window_gaps(i,2))  = NaN;
            end
            plot(C3)
        end

        
        if isempty(nosave)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Plot the property and its autocor.
            %
            if isempty(net_title)
                figtitle = {[patient_title ' - ' property_title]};
            else
                figtitle = {[patient_title ' - ' property_title], [net_title]};
            end

            % Plot property WITH sleep stages...
            % Set annot to empty to avoid plotting sleep stages
            annot = [];%sleep_annot;    
            if ~isempty(annot)
                annot(:,1) = mat2cell(cell2mat(annot(:,1))./(5*srate),...
                                        ones(size(annot(:,1),1),1));
            end
            g = plot_with_events(C3,3600/5,annot,starttime,...
                            figtitle,seizstart/(5*srate),seizend/(5*srate),...
                            sleepstart/(5*srate),sleepend/(5*srate));

            % Save property plot
            if ~exist(figdir,'dir') mkdir(figdir); end;
            saveas(g, [figdir '/' property net_filename '.fig']);
    %         saveas(g, [figdir '/' property net_filename '.jpg']);
    %         print(g,'-dpdf','-r300',[figdir '/' property net_filename '.pdf']);
            savefig([figdir '/' property net_filename],g,'jpeg','-r150')
            close;

            % Figure plotting the periodicity
            h = figure;
            leave_out_values = 19*3600/5;
            % Plot autocorrelation's both positive and negative values...
            %plot(x_axis_values_per(leave_out_values+1:2*timemoments-leave_out_values-1),normalized_autocorrelation(leave_out_values+1:2*timemoments-leave_out_values-1,:));
            % ... or plot only positive values
            plot(x_axis_values_per(timemoments+1:2*timemoments-leave_out_values-1),normalized_autocorrelation(timemoments+1:2*timemoments-leave_out_values-1,:));
    %         title([patient_title ' - ' property_title ' ' net_title 'autocor.']);
            figtitle{1,end} = [figtitle{1,end} ' autocor.'];
            title(figtitle);
            xlabel(x_axis_title_per);
            ylim([-0.3 0.6]);
            set(findall(gcf,'type','text'),'fontSize',20);
            set(findall(gcf,'type','axes'),'fontsize',17);
    %         set(gca,'LineWidth',0.4);
    %         set(gcf,'PaperUnits','inches');
    %         set(gcf,'PaperSize', [12.5 10]);
    %         set(gcf,'PaperPosition',[0.5 0.5 11.5 9]);

            saveas(h, [figdir '/periodicity_' property net_filename '.fig']);
    %         saveas(h, [figdir '/periodicity_' property net_filename '.jpg']);
    %         print(h,'-dpdf','-r300',[figdir '/periodicity_' property net_filename '.pdf']);
            savefig([figdir '/periodicity_' property net_filename],h,'jpeg','-r150');
            close;
        end % if nosave
    end    % for networks
end