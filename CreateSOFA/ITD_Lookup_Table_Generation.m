function [] = ITD_Lookup_Table_Generation(projectName,subjectName,fs)
   
    % Variable for FS folder name as a string
    fsFolder = int2str(round(fs/1000));
    
    % ---LOAD FILE PATHS--- %

    hrirPath = strcat('Audio/',projectName,'/HRIR_Trim/',subjectName,'/',fsFolder);
    hrirDirectory = dir(sprintf('%s/*.wav',hrirPath));

    % --------------------- %

    for k =1:length(hrirDirectory)

        fileName = hrirDirectory(k).name;

        % Scan and store angles
        [azi_angle,ele_angle] = find_azi_ele(fileName);
        
        itd_out(k,1) = azi_angle;
        itd_out(k,2) = ele_angle;
        
        % Load audio file 
        hrir = audioread(sprintf('%s/%s',hrirPath,fileName));

        % Find ITD
        maxLag = round(0.0011*fs);

        left = hrir(:,1);
        right = hrir(:,2);

        itd = finddelay(left,right,maxLag);
        itd_out(k,3) = (itd/fs);

        itd_out_filepath = strcat('Audio/',projectName,'/SOFAFiles/lookUpTables/');
        
        if 0==exist(itd_out_filepath,'file')
            disp('Creating File...');
            disp(itd_out_filepath);
            mkdir(itd_out_filepath);
        end
        % Write to text file
        idt_out_name = strcat(itd_out_filepath,'/',subjectName,'_ITD_Lookup_Table.txt');

        fid = fopen(idt_out_name,'w');
        fprintf(fid,'%0i \t %0i \t %0i\r\n',itd_out');
        fclose(fid);
        
    end
    
    function [azi,ele] = find_azi_ele(name)
        [token,remain] = strtok(name,'_');
        [azi,remain] = strtok(remain,'_');
        [ele,remain] = strtok(remain,'_ele');
        
        azi = str2num(azi);
        ele = str2num(ele);
        
    end

end