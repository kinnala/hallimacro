% write here the percentages of different columns
projects=[0 0.169 0 0];
% save 'Kuukausinäkymä' from halli to the following filename
hallisrc='Halli.html';

% no reason to modify below this
for itr=31:-1:27
    [~,chk]=system(['grep -o "&nbsp;',num2str(itr),'" ',hallisrc,' | wc -l']);
    chk=str2num(chk);
    if chk==1
        ndays=itr;
        break
    end
end
%[~,ndays]=system(['grep "<tr " ',hallisrc,' | wc -l']);
%ndays=str2num(ndays)-3; % 1 header row + 2 footer rows

[~,ninputs]=system(['grep "vsectcode" ',hallisrc,' | wc -l']);
ninputs=str2num(ninputs);
nprojects=ninputs/ndays;

[~,fmonday]=system(['grep -o "Ma&nbsp;[0-9]" -m 1 ',hallisrc,' | grep -o "[0-9]"']);
fmonday=str2num(fmonday(1));

% do some sanity checks before continuing
if sum(projects)>1
    error('Project percentages sum up to a number larger than one!');
end
if ndays>31
    error('The deduced information claims that there are more than 31 days in the month. Either Halli has been updated or the scraping is incorrect (= bug in code).');
end

workhours=zeros(ndays,nprojects);

workdays=fmonday:7:ndays;
workdays=bsxfun(@plus,workdays,(0:4)');
workdays=workdays(:);
workdays=[(1:(fmonday-3))';workdays];
workdays(find(workdays>ndays))=[];

projecthours=projects*length(workdays)*7.25;

for itr=1:nprojects
    for jtr=workdays'
        hoursperday=sum(workhours');
        if hoursperday(jtr)>=7.25
            continue
        end
        freehours=7.25-hoursperday(jtr);
        if projecthours(itr)<=freehours
            workhours(jtr,itr)=projecthours(itr);
            projecthours(itr)=0;
            break
        elseif projecthours(itr)>freehours
            workhours(jtr,itr)=freehours;
            projecthours(itr)=projecthours(itr)-freehours;
        end
    end
end

display('Does the following table look fine to you?');
display(workhours);
display('Press Ctrl-C to cancel or any other key to continue ...');
pause;

h=fopen('halli.xmacro','w');
workhours=round(workhours*1000)/1000;
workhours=workhours';
for itr=workhours(:)'
    fprintf(h,['KeyStrPress BackSpace\n']);
    fprintf(h,['KeyStrRelease BackSpace\n']);
    if itr~=0
        for jtr=num2str(itr)
            if jtr=='.'
                fprintf(h,['KeyStrPress comma\n']);
                fprintf(h,['KeyStrRelease comma\n']);
            else
                fprintf(h,['KeyStrPress ',jtr,'\n']);
                fprintf(h,['KeyStrRelease ',jtr,'\n']);
            end
        end
    end
    fprintf(h,['KeyStrPress Tab\n']);
    fprintf(h,['KeyStrRelease Tab\n']);
    fprintf(h,['KeyStrPress Tab\n']);
    fprintf(h,['KeyStrRelease Tab\n']);
end
fclose(h);