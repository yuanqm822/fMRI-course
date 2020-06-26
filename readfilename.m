function filesName = readfilename(path)
%path = 'G:\Qiming_Rest\Activation_analysis\Preprocessed\FunImgARCFWS\sub101';
filesInfo = dir(path);

marker = filesInfo(end).name;
marker = marker(end-2:end);

if strcmp(marker,'img') == 1
    filesName = {filesInfo(4:2:end).name}';
    for i = 1:length(filesName)
        filesName{i} = [path, filesep, filesName{i}, ',1'];
    end
elseif length(filesInfo) >4
    filesInfo = dir(fullfile(path,'*nii'));
    FourDfile = {filesInfo.name};
    for i = 1:length(filesInfo)
        filesName{i,1} = [path, filesep, FourDfile{i},',1'];
    end
else
    filesInfo = dir(fullfile(path,'*nii'));
    FourDfile = filesInfo.name;
    for i = 1:120
        filesName{i,1} = [path, filesep, FourDfile,',',num2str(i)];
    end
end
