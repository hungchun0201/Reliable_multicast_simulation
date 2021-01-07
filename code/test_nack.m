%% nack-based retransmission
function [nack_ave_trans_latency,nack_ave_resource_usage,nack_reliability,nack_ave_bottleneck_UE_latency] = test_nack(total_packets,e,pkt_per_round,nack_m,XOR_pkt_num,L_constraint,T_RTT,RB_data,RB_feedback)
    
    total_simulation = 10^5;
    total_latency = 0;
    total_resource_usage = 0;
    success_times = 0;
    total_bottleneck_UE_latency = 0;

    parfor simulation_time=1:total_simulation %par
        success_UE_matrix = zeros(total_packets,floor(L_constraint/T_RTT)+1); % For each row representing different pkts, the relationship between number of transmission and success number of UE
        tx_cnt_list = zeros(1,total_packets); % For each pkt, how many times it is transmitted?
        tx_complete_list = zeros(1,total_packets); % 1 stands for success, 0 stands for failure.
        tx_pkt_id = 1:pkt_per_round;
        next_pkt = pkt_per_round+1;
        trnasmission_cnt = 0;

        e_new = zeros(pkt_per_round,numel(e));
        for k=1:length(tx_pkt_id) 
            e_new(k,:)= e;
        end
        
        while(~isempty(tx_pkt_id))
            
            
            % Transmission counter + 1
            trnasmission_cnt = trnasmission_cnt + 1;
            tx_cnt_list(tx_pkt_id) = tx_cnt_list(tx_pkt_id)+1;
            
            r = UE_receive_sim(e_new,length(tx_pkt_id),nack_m,XOR_pkt_num);
            total_resource_usage = total_resource_usage + (RB_data+RB_feedback)*(length(tx_pkt_id)*nack_m+XOR_pkt_num);
            % disp(total_resource_usage);
            
            for pkt_id = 1:length(tx_pkt_id)
                % pkt_id : position in tx_pkt_id
                % tx_pkt_id(pkt_id) : list of current transmitted pkt id

            % --------------------- Update Success UE in this round. --------------------- %
                % disp(tx_pkt_id);
                %disp(sum(success_UE_matrix(tx_pkt_id(pkt_id),:)));
                success_UE_matrix(tx_pkt_id(pkt_id),tx_cnt_list(tx_pkt_id(pkt_id))) = numel(e)...
                - sum(success_UE_matrix(tx_pkt_id(pkt_id),:)) - sum(r(pkt_id,:));
                % disp(success_UE_matrix);
                % -------------------------------- Explanation ------------------------------- %

                    % Assume the sum(r(pkt_id,:)), i.e. # of remaining failure UE is
                    % [7 3 3 2 0], and the total number of UE, i.e. numel(e), is 30.
                    % The expected success_UE_matrix(tx_pkt_id(pkt_id),:), 
                    % which is initialized as [0 0 0 0 0], should be [23 4 0 1 2].
                    % For the first value, it can be calculated by 30 - 0 - 7 = 23. The current success_UE_matrix is [23 0 0 0 0].
                    % For the second value, it can be calculated by 30 - 23 - 3 = 4. The current success_UE_matrix is [23 4 0 0 0].
                    % For the third value, it can be calculated by 30 - 23 - 4 - 3 = 0. The current success_UE_matrix is [23 4 0 0 0].
                    % For the forth value, it can be calculated by 30 - 23 - 4 - 2 = 1. The current success_UE_matrix is [23 4 0 1 0].
                    % For the fifth value, it can be calculated by 30 - 23 - 4 - 1 - 0 = 2. The current success_UE_matrix is [23 4 0 1 2].
                    % Therefore, we can infer that the value of current success UE can be calculated by numel(e)(30)- 
                    % success_UE_matrix(tx_pkt_id(pkt_id),:) - sum(r(pkt_id,:));


                if(sum(r(pkt_id,:))==0)

                    tx_complete_list(tx_pkt_id(pkt_id)) = 1;

                    if(next_pkt > total_packets)
                        tx_pkt_id(pkt_id) = 0;
                    else
                        tx_pkt_id(pkt_id) = next_pkt;
                        next_pkt = next_pkt+1;
                    end

                    e_new(pkt_id,:) = e;

                elseif(tx_cnt_list(pkt_id)>floor(L_constraint/T_RTT))
                    if(next_pkt > total_packets)
                        tx_pkt_id(pkt_id) = 0;
                    else
                        tx_pkt_id(pkt_id) = next_pkt;
                        next_pkt = next_pkt+1;
                    end
                    e_new(pkt_id,:) = e;
                end
                
                for i = 1:length(r(pkt_id,:)) % 成功的人要從e中踢除
                    if(r(pkt_id,i)==0)% success
                        e_new(pkt_id,i) = 0; %e_new = [e_new 0];
                    else %Fail
                        e_new(pkt_id,i) = e(i); % e_new = [e_new e(i)];
                    end
                end
            
            end
            
            tx_pkt_id(~tx_pkt_id) = [];
            

        end
        success_times = success_times + (sum(tx_complete_list)==total_packets);
        total_latency = total_latency + sum(sum(success_UE_matrix).*(3*(1:floor(L_constraint/T_RTT)+1))/numel(e))*T_RTT;
        total_bottleneck_UE_latency =  total_bottleneck_UE_latency + trnasmission_cnt*T_RTT;

    end
    nack_reliability = success_times/total_simulation;
    nack_ave_trans_latency = total_latency/total_simulation;
    nack_ave_resource_usage = total_resource_usage/total_simulation;
    nack_ave_bottleneck_UE_latency = total_bottleneck_UE_latency/total_simulation;
end


%         for trans_time_cnt=1:total_packets/pkt_per_round
%             trans_times_one_round = 0;
%             fail_UE_in_each_round = zeros(1,1);
%             e_new = e;
%             while(trans_times_one_round <= floor(L_constraint/T_RTT))
%                 trans_times_one_round = trans_times_one_round+1;
%                  % Sample by error prob.
%                 %disp(sum(r));
%                 fail_UE_in_each_round(trans_times_one_round) = sum(r); 
%                 Fail_UE_matrix(trans_time_cnt,:) = r;
%                 if(sum(r)==0)
%                     % success_times = success_times +1;
%                     break
%                 elseif(trans_times_one_round>)
%                     break
%                 end
%                 % Calculate trans_time
                
                
%                 e_new = zeros(1,numel(e));
%                 for i = 1:length(r) % 成功的人要從e中踢除
%                     if(r(i)==0)% success
%                         e_new(i) = 0;
%                         %e_new = [e_new 0];
%                     else %Fail
%                         e_new(i) = e(i);
%                         % e_new = [e_new e(i)];
%                     end
%                 end
                    
%             end
%             total_resource_usage = total_resource_usage+ trans_times_one_round*(RB_data+RB_feedback)*(pkt_per_round*nack_m+XOR_pkt_num);
%             %% Calculate UE average latency
%             one_sim_latency = 0;
%             for i=1:length(fail_UE_in_each_round)
%                 %disp(time);
%                 if(i==1)
%                     one_round_success_UE = numel(e)-fail_UE_in_each_round(i);
%                 else
%                     one_round_success_UE = fail_UE_in_each_round(i-1)-fail_UE_in_each_round(i);
%                 end
%                 one_sim_latency = one_sim_latency + one_round_success_UE*T_RTT*i;            
%             end
%             total_latency = total_latency + one_sim_latency/numel(e);
%             total_bottleneck_UE_latency = total_bottleneck_UE_latency + T_RTT*length(fail_UE_in_each_round);
%         end

%         if(sum(Fail_UE_matrix,[1,2])==0)
%             success_times = success_times +1;
%         end
%     end
%     nack_reliability = success_times/total_simulation;
%     nack_ave_trans_latency = total_latency/total_simulation;
%     nack_ave_resource_usage = total_resource_usage/total_simulation;
%     nack_ave_bottleneck_UE_latency = total_bottleneck_UE_latency/total_simulation;
    
%     %fprintf("nack trans_times_one_round: %d, resource usage: %d and reliability is : %f",ave_trans_times_one_round,ave_resource_usage,reliability);
% end