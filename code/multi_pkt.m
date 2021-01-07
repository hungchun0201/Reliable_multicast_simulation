format long
% parpool('local',12);
%% Parameters
n = 30;

L_constraint = 12;
T_RTT = 2;

total_packets = 18;
pkt_per_round = 2;
XOR_pkt_num = 1;

blind_upper_bound = 200; %blind_retransmission_upperbound
nack_m = 2; % packet num in one nack_based transmission 

rel_constraint = 0.9999;

RB_data = 1;
RB_feedback = 0;
%% Run simulation: 
tic
data_point_num = 12;
x = [];

theoritical_reliability_list = zeros(1,data_point_num);

blind_success_prob_list = [];
blind_resource_list = [];

nack_ave_trans_latency_list = [];
nack_ave_resource_usage_list = [];
nack_reliability_list = [];
nack_ave_bottleneck_UE_latency_list = [];

XOR_nack_ave_trans_latency_list = [];
XOR_nack_ave_resource_usage_list = [];
XOR_nack_reliability_list = [];
XOR_nack_ave_bottleneck_UE_latency_list = [];

parfor i = 1:data_point_num %par
    % x-axis
    e = get_error_prob_list(n);
    x =[x mean(e)];
    %fprintf("Averaeg error prob: %f, and std is: %f\n",mean(e),std(e));
    
    % Blind retransmission
    blind_trans_time = estimate_blind_m(e,rel_constraint,blind_upper_bound,total_packets);

    theoritical_reliability_list(i) = prod(1-e.^blind_trans_time)^total_packets;

    [blind_resource...
        ,blind_success_prob]...
        = blind_retransmission_sim(total_packets,e,blind_trans_time,RB_data,"Monte Carlo");
    
    blind_success_prob_list = [blind_success_prob_list blind_success_prob];
    blind_resource_list = [blind_resource_list blind_resource];
    
    % Nack-based retransmission
    [ave_trans_latency,...
        ave_resource_usage,...
        reliability,...
        nack_ave_bottleneck_UE_latency]...
        = nack_based_XOR_sim(total_packets, e, pkt_per_round, nack_m, 0, L_constraint, T_RTT, RB_data, RB_feedback);
    
    nack_ave_trans_latency_list = [nack_ave_trans_latency_list ave_trans_latency];
    nack_ave_resource_usage_list = [nack_ave_resource_usage_list ave_resource_usage];
    nack_reliability_list = [nack_reliability_list reliability];
    nack_ave_bottleneck_UE_latency_list = [nack_ave_bottleneck_UE_latency_list nack_ave_bottleneck_UE_latency];
    
    % Nack-based retransmission with network coding
    [XOR_ave_trans_latency,...
    XOR_ave_resource_usage,...
    XOR_reliability,...
    XOR_nack_ave_bottleneck_UE_latency]...
        = nack_based_XOR_sim(total_packets,e,pkt_per_round,nack_m,XOR_pkt_num,L_constraint,T_RTT,RB_data,RB_feedback);
    
    XOR_nack_ave_trans_latency_list = [XOR_nack_ave_trans_latency_list XOR_ave_trans_latency];
    XOR_nack_ave_resource_usage_list = [XOR_nack_ave_resource_usage_list XOR_ave_resource_usage];
    XOR_nack_reliability_list = [XOR_nack_reliability_list XOR_reliability];
    XOR_nack_ave_bottleneck_UE_latency_list = [XOR_nack_ave_bottleneck_UE_latency_list XOR_nack_ave_bottleneck_UE_latency];
end

%% Plot figure: 
reliability_baseline = linspace(rel_constraint,rel_constraint,data_point_num);
     % x, nack_ave_resource_usage_list, 'g', ...
     %      x, blind_resource_list, 'm', ...
clf
subplot(1,3,1);
plot(x, reliability_baseline,'g');
hold on
scatter(x, blind_success_prob_list, 10,'r','filled');
hold on
scatter(x, nack_reliability_list, 10,'b','filled');
hold on
scatter(x, XOR_nack_reliability_list, 10,'g','d','filled');
hold on
scatter(x, theoritical_reliability_list, 10,'magenta','filled');
hold off
xlabel('average error probability');
ylabel('Reliability');
legend('baseline','blind\_retransmission','nack\_based\_retransmission','XOR\_nack\_based\_retransmission','Theorical','Location','southwest');
title(['error prob. v.s. Reliability (n=' num2str(n) ', total\_packets\_num=' num2str(total_packets) newline ' ,packets\_per\_round = ' num2str(pkt_per_round) ' ,nack\_m = ' num2str(nack_m) ')']);

subplot(1,3,2);
scatter(x, blind_resource_list, 10,'r','filled');
hold on
scatter(x, nack_ave_resource_usage_list, 10,'b','filled');
hold on
scatter(x, XOR_nack_ave_resource_usage_list, 10,'g','filled');
hold off
xlabel('average error probability');
ylabel('Resource');
legend('blind\_retransmission','nack\_based\_retransmission','XOR\_nack\_based\_retransmission','Location','best');
title(['error prob. v.s. Resource Usage (n=' num2str(n) ', total\_packets\_num=' num2str(total_packets) newline ' ,packets\_per\_round = ' num2str(pkt_per_round) ' ,nack\_m = ' num2str(nack_m) ')']);

subplot(1,3,3);
scatter(x, nack_ave_trans_latency_list, 10,'magenta','filled');
hold on
scatter(x, nack_ave_bottleneck_UE_latency_list, 10,'magenta');
hold on
scatter(x, XOR_nack_ave_trans_latency_list, 10,'cyan','filled');
hold on
scatter(x, XOR_nack_ave_bottleneck_UE_latency_list, 10,'cyan');
hold off
xlabel('average error probability');
ylabel('Latency(ms)');
legend('nack\_ave\_trans\_latency',' nack\_ave\_bottleneck\_UE\_latency','XOR\_nack\_ave\_trans\_latency',' XOR\_nack\_ave\_bottleneck\_UE\_latency','Location','best');
title(['error prob. v.s. Latency' ' (n=' num2str(n) ',total\_packets\_num=' num2str(total_packets) newline ' ,packets\_per\_round = ' num2str(pkt_per_round) ' ,nack\_m = ' num2str(nack_m) ',L_{constraint}='...
     num2str(L_constraint) 'ms, RTT=' num2str(T_RTT) 'ms)']);
time = toc;
fprintf("Elapsed time: %g\n",time);
%saveas(gcf, sprintf('test_.png'));
% delete(gcp('nocreate'))




