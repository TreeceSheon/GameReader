%   This script should work for arbitary dataset reconstructed using
%   methods in cs_mri.m only if results are named by the following fomat:
%   cs_mri + (1 tag for slices) + (1 tag for echo)
%   For different dataset merge, change load *.mat and size while others
%   remain.
clear;
load cs_mri01.mat;
load cs_mri11.mat;
load cs_mri02.mat;
load cs_mri12.mat;
load cs_mri03.mat;
load cs_mri13.mat;
load cs_mri04.mat;
load cs_mri14.mat;
load cs_mri05.mat;
load cs_mri15.mat;
load cs_mri06.mat;
load cs_mri16.mat;
load cs_mri07.mat;
load cs_mri17.mat;
load cs_mri08.mat;
load cs_mri18.mat;

result = whos;
size = [256,256,132,8];

[img_full,img_npc,img_pc,img_zhao] = deal(zeros(size));
slices_length = size(3);
mid = slices_length / 2;
for i = 1:length(result)
    name = result(i).name;
    echo = str2num(name(end));
    display(name)
    switch name(5)
        case 'f'
            temp_full =  eval(name);
            if name(9) == '0'
                img_full(:,:,1:mid,echo) =temp_full(:,:,1:mid,echo);
            else
                img_full(:,:,mid+1:slices_length,echo) =temp_full(:,:,mid+1:slices_length,echo);
            end
        case 'n'
            temp_npc = eval(name);
            if name(8) == '0'
                img_npc(:,:,1:mid,echo) = temp_npc(:,:,1:mid,echo);
            else
                img_npc(:,:,mid+1:slices_length,echo) =temp_npc(:,:,mid+1:slices_length,echo);
            end
        case 'p'
            temp_pc = eval(name);
            if name(7) == '0'
                img_pc(:,:,1:mid,echo) = temp_pc(:,:,1:mid,echo);
            else
                img_pc(:,:,mid+1:slices_length,echo) =temp_pc(:,:,mid+1:slices_length,echo);
            end
        case 'z'
            temp_zhao = eval(name);
            if name(9) == '0'
                img_zhao(:,:,1:mid,echo) = temp_zhao(:,:,1:mid,echo);
            else
                img_zhao(:,:,mid+1:slices_length,echo) = temp_zhao(:,:,mid+1:slices_length,echo);
            end
    end
end
save('allmerged.mat')

                
            
          

