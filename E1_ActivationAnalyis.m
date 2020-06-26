clc; clear;
sub = [101:114];
outputdir = fullfile('Results','firstlevel');
all_con_dir = fullfile(fileparts(outputdir),'secondlevel','orig');
mkdir(all_con_dir)
mask = 'grey.nii';
fmri_preprocessed = fullfile(fileparts(pwd),'Data','Preprocessed');
Sessions = {'FunImgARWS'};
parfor s= 1:length(sub)
    sid = sub(s);
    matlabbatch =[];
    disp(['sub',num2str(sid)])
    tmpdir = fullfile(outputdir,['sub',num2str(sid)]);
    mkdir(tmpdir)
    %% GLM
    spm('defaults', 'FMRI');
    matlabbatch{1}.spm.stats.fmri_spec.dir = {tmpdir};
    matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
    matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
    matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
    %
    for r = 1:length(Sessions)
        filesName = readfilename( fullfile(fileparts(pwd),'Data','Preprocessed',Sessions{r},['sub' num2str(sid)]));
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = filesName;
        disp(length(filesName));
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).name = 'T';
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).onset = [0,60,120,180];
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).duration = 30;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(1).orth = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).name = 'R';
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).onset = [30,90,150,210];
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).duration = 30;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(2).orth = 1;
    % head motions regression
        rp = dir(fullfile(fileparts(pwd),'Data','Preprocessed','RealignParameter',['sub',num2str(sid)],['rp*']));
        rp = fullfile(rp.folder,rp.name);
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = {rp};
        matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = 128;
    end 
    %--------
    matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
    matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
    matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
    matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
    matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
    matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
    matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
    matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'taskeffect';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights =repmat([1 -1],[1,r]);
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
    matlabbatch{3}.spm.stats.con.delete = 0;
    %run and copy files
    spm_jobman('run', matlabbatch,cell(0, 1));
    con_dir = fullfile(tmpdir,'con_0001.nii');
    copyfile(con_dir,[all_con_dir,'/taskeffect_sub',num2str(sid),'.nii'],'f')
end
