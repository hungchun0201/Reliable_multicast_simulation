%% nack-based retransmission
function [nack_ave_trans_latency,nack_ave_resource_usage,nack_reliability,nack_ave_bottleneck_UE_latency] = nack_based_XOR_sim(total_packets,e,pkt_per_round,nack_m,XOR_pkt_num,L_constraint,T_RTT,RB_data,RB_feedback)
    
    total_simulation = 10^5;
    total_latency = 0;
    total_resource_usage = 0;
    success_times = 0;
    total_bottleneck_UE_latency = 0;

    for simulation_time=1:total_simulation
        Fail_UE_per_round = zeros(total_packets/pkt_per_round,length(e));
        
        for trans_time_cnt=1:total_packets/pkt_per_round
            trans_times_one_round = 0;
            fail_UE_in_each_round = zeros(1,1);
            e_new = e;
            while(trans_times_one_round <= floor(L_constraint/T_RTT))
                trans_times_one_round = trans_times_one_round+1;
                r = UE_receive_sim(e_new,pkt_per_round,nack_m,XOR_pkt_num); % Sample by error prob.
                %disp(sum(r));
                fail_UE_in_each_round(trans_times_one_round) = sum(r); 
                Fail_UE_per_round(trans_time_cnt,:) = r;
                if(sum(r)==0)
                    % success_times = success_times +1;
                    break
                elseif(trans_times_one_round>floor(L_constraint/T_RTT))
                    break
                end
                % Calculate trans_time
                
                
                e_new = zeros(1,numel(e));
                for i = 1:length(r) % 成功的人要從e中踢除
                    if(r(i)==0)% success
                        e_new(i) = 0;
                        %e_new = [e_new 0];
                    else %Fail
                        e_new(i) = e(i);
                        % e_new = [e_new e(i)];
                    end
                end
                    
            end
            total_resource_usage = total_resource_usage+ trans_times_one_round*(RB_data+RB_feedback)*(pkt_per_round*nack_m+XOR_pkt_num);
            %% Calculate UE average latency
            one_sim_latency = 0;
            for i=1:length(fail_UE_in_each_round)
                %disp(time);
                if(i==1)
                    one_round_success_UE = numel(e)-fail_UE_in_each_round(i);
                else
                    one_round_success_UE = fail_UE_in_each_round(i-1)-fail_UE_in_each_round(i);
                end
                one_sim_latency = one_sim_latency + one_round_success_UE*T_RTT*i;            
            end
            total_latency = total_latency + one_sim_latency/numel(e);
            total_bottleneck_UE_latency = total_bottleneck_UE_latency + T_RTT*length(fail_UE_in_each_round);
        end

        if(sum(Fail_UE_per_round,[1,2])==0)
            success_times = success_times +1;
        end
    end
    nack_reliability = success_times/total_simulation;
    nack_ave_trans_latency = total_latency/total_simulation;
    nack_ave_resource_usage = total_resource_usage/total_simulation;
    nack_ave_bottleneck_UE_latency = total_bottleneck_UE_latency/total_simulation;
    
    %fprintf("nack trans_times_one_round: %d, resource usage: %d and reliability is : %f",ave_trans_times_one_round,ave_resource_usage,reliability);
end