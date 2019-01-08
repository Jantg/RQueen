function [hoge,arx_init] = run_gibbs(x,p,del,m0,C0,s0,n0,missing_id,iter,val_lim,run_val)
%x = PI(38:88)
%p = 1;
%del = [0.95 0.99]
%m0 = ones(p,1)
%C0 = eye(p)
%s0 = 1
%n0 = 1
%missing_id = PI_miss(38:88)
[m,C,n,s,e,mf,Cf,sf,nf,ef,qf,arx_init] = tvarFFBS_mod(x,p,del,m0,C0,s0,n0,missing_id);
hoge = zeros(length(x),iter);
%means = zeros(100,1);
arx_init(imag(arx_init)~=0) =x(imag(arx_init)~=0)-mean(x);
flag = true;
while any(isnan(arx_init))||flag == true  || any(abs(arx_init)>val_lim)%|| any(abs(s)>3)
    %flag = true;
    [m,C,n,s,e,mf,Cf,sf,nf,ef,qf,arx_init] = tvarFFBS_mod(x,p,del,m0,C0,s0,n0,missing_id);
    if any(isnan(arx_init))==false %&& all(imag(arx_init)==0)
        for i=1:length(arx_init)
            flag = flag*all(abs(eig(C(:,:,i)))<1);
            %disp(flag)
        end
    end
end
flag = true;
arx_init(imag(arx_init)~=0) = x(imag(arx_init)~=0)-mean(x);
nruns = 0;
back = 0;
for i=1:iter
    arx = zeros(length(arx_init),1);
    arx(1) = nan;
    while any(isnan(arx(1:end))) ||flag==true||any(abs(arx)>val_lim)%||any(abs(s)>3)
        %flag = true;
        [m,C,n,s,e,mf,Cf,sf,nf,ef,qf,arx] = tvarFFBS_mod(arx_init,p,del,m0,C0,s0,n0,missing_id);
        nruns = nruns+1;
        if nruns>run_val
            disp('Hit unlikely spots')
            disp(back)
            if i<3
                back = 0;
            else
                back = randi([2 min([15 i-1])],1,1)+back;
                if i-back<1
                    back = i-1;
                end
            end
            arx_init = hoge(:,(i-back));
            nruns = 0;
        end
        if any(isnan(arx))==false %&&all(imag(arx)==0)
            for j=1:length(arx_init)
                flag = flag*all(abs(eig(C(:,:,j)))<1);
            end
        end   
    end
    back = 0;
    fprintf('%d runs',nruns);fprintf('\b\n');
    nruns = 0;
    disp(i)
    %disp(arx_init(imag(arx)~=0))
    arx(imag(arx)~=0) = arx_init(imag(arx)~=0);
    arx_init(missing_id) = arx(missing_id);
    %arx_init = real(arx_init);


    hoge(:,i) = arx_init;
    %arx_init = real(arx);
    %arx_init(PI_miss(38:88)==1) = real(arx(PI_miss(38:88)==1));
end



