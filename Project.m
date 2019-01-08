%% Check that imputation algo works

load salesindex
T_index = length(index);
miss = rand(T_index,1)<1-mean(PI_miss(38:88));
index_ = repmat(nan,[T_index 1]);
index_(miss) = index(miss);
index_w_na = index_;
index_miss = isnan(index_);
mu = mean(index_,'omitnan');
if isnan(index_(1))
    index_(1) = mu;
end
for i=2:T_index
    if index_miss(i)
        index_(i) = index_(i-1);    
    end
end

for i=2:(T_index-1)
    if index_miss(i)==1
        index_(i) = (index_(i) +index_(i+1))/2;
    end
end

x = index_;
missing_id = index_miss;
iter = 10000;
p = 3;
s0 = 0.5;
m0 = zeros(p,1);
C0 = eye(p);
n0 = 3;
del = [0.96 0.99];
[hoge,arx_init] = run_gibbs(x',p,del,m0,C0,s0,n0,missing_id,iter,5);
%interval = quantile(real(hoge(missing_id,:)),[0.025 0.975],2);
date = dates.x;
date = date(38:88);
interval = quantile(hoge,[0.05 0.95],2);
lower = interval(:,1); upper = interval(:,2);
nan_values = repmat(nan,[T_index 1]);
nan_values(isnan(index_w_na)) = index(isnan(index_w_na));
%lower(missing_id) = interval(:,1);upper(missing_id) = interval(:,2);
ciplot(lower,upper,1:72,[.85 .85 .85]); hold on;%plot(index);
plot(index_w_na,'-o');
plot(nan_values,'bo');title('Gibbs impuation of index data');


%% First, fill in missing values of the predictors with moving average and do missing valu impu

PI = projecdf.infection_rate;
mu = mean(PI,'omitnan');
PI = log(PI./(1-PI));
T = length(PI);
PI_w_na = PI(38:88);
PI_miss = isnan(PI)|isinf(PI);
PI(1) = log(mu./(1-mu));
for i=2:T
    if PI_miss(i)
        PI(i) = PI(i-1);    
    end
end

for i=2:T
    if PI_miss(i)==1
        PI(i) = (PI(i) +PI(i+1))/2;
    end
end

x = PI(38:88);
mu_pi = mean(x);
p = 3;
del = [0.96 0.99];
m0 = ones(p,1);
C0 = eye(p);
s0 = 0.7;
n0 = 3;
missing_id = PI_miss(38:88);
iter = 10000;
warning off;
[hoge,arx_init] = run_gibbs(x,p,del,m0,C0,s0,n0,missing_id,iter,5,100000);
interval = quantile(hoge,[0.025 0.975],2);
lower =interval(:,1); upper = interval(:,2);
med_miss = median(hoge,2);
med_miss(~isnan(PI_w_na)) = nan;
%lower(missing_id) = interval(:,1);upper(missing_id) = interval(:,2);
ciplot(lower,upper,1:length(lower),[.85 .85 .85]); hold on;a1 = plot(PI_w_na-mu_pi,'-o');
a2 = plot(med_miss,'o');M1 = 'Observed Values'; M2 = 'Median Prediction of Missing Data';
legend([a1;a2],M1,M2);
title('Prediction interval,median and observed data');
date = datesnew.x;
date = date(38:88);
xticks([2:5:51]);xtickangle(45);xticklabels({datestr(date(2:5:51))});xlim([0 length(med_miss)+1]);
%plot(index_w_na);
%plot(index,'o');title('Gibbs impuation of index data');hold off;
%x(missing_id) = real(arx_init(missing_id))+mu_pi;

%% O2 temp data

O2 = projectdfall.o2;
TP = projectdfall.temp;
mu_o2 = mean(O2,'omitnan');
mu_tp = mean(TP,'omitnan');
%O2 = log(O2./(1-O2));
T = length(O2);
O2_w_na = O2(38:88);
TP_w_na = TP(38:88);
O2_miss = isnan(O2)|isinf(O2);
TP_miss = isnan(TP)|isinf(TP);
%O2(1) = mu_o2;
%TP(1) = mu_tp;

for i=2:T
    if O2_miss(i)
        O2(i) = O2(i-1); 
        TP(i) = TP(i-1);
    end
end

for i=2:(T-1)
    if O2_miss(i)
        O2(i) = (O2(i) +O2(i+1))/2;
        TP(i) = (TP(i) +TP(i+1))/2;
    end
end

x_o = O2(38:88);
x_t = TP(38:88);
mu_o = mean(x_o);
mu_t = mean(x_t);

p = 1;
del = [0.96 0.99];
m0 = ones(p,1);
C0 = eye(p);
s0 = 2;
n0 = 15;
missing_id_o = O2_miss(38:88);
%missnig_id = TP_miss(38:88);
iter = 10000;
warning off;
[hoge_o,arx_init_o] = run_gibbs(x_o,p,del,m0,C0,s0,n0,missing_id_o,iter,50,1000);
[hoge_t,arx_init_t] = run_gibbs(x_t,p,del,m0,C0,s0,n0,missing_id_o,iter,50,500);

%% Dynamic regression
%part below contains Mike's code so removed from this file
