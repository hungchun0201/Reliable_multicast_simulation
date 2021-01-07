%% blind retransmission
function [blind_resource,blind_success_prob] = blind_retransmission_sim(total_packets,e,blind_trans_time,RB_data,type)
    if(type=="direct")
        %% Using error_prob directly to estimate
        blind_success_prob = prod(1.-e.^blind_trans_time);
    elseif(type=="Monte Carlo")
        %% Using Simulation to estimate
        total_simulation = 10^5;
        blind_success_cnt = 0;
        parfor simulation_time=1:total_simulation
            Fail_UE_per_round = zeros(total_packets,length(e));
            for trans_time=1:total_packets
                Fail_UE_per_round(trans_time,:) = binornd(1,e.^blind_trans_time);
            end
            if(sum(Fail_UE_per_round,[1,2])==0)
                blind_success_cnt = blind_success_cnt+1;
            end
        end
        blind_success_prob = blind_success_cnt/total_simulation;
    end
    blind_resource = blind_trans_time*RB_data*total_packets;
    %fprintf("blind_success_prob: %f, resource usage: %d \n",blind_success_prob,blind_resource);
end