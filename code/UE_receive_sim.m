function r = UE_receive_sim(e_new, pkt_num, nack_m, XOR_pkt_num)
    success_cnt_in_each_pkt_list = zeros(pkt_num, length(e_new));

    % ------------------------ Consider original nack pkt ------------------------ %

    for i = 1:pkt_num
        success_cnt_in_each_pkt_list(i, :) = binornd(1, e_new(i,:).^nack_m);
    end
    
    fail_pkt_list = sum(success_cnt_in_each_pkt_list,1);

    % ----------------------------- Consider XOR pkt ----------------------------- %
    if (XOR_pkt_num>0)
        for j = 1:length(e_new)
            
            if (fail_pkt_list(j) == 1)
                isSuccess = rand(1, 'like', e_new(j)) > e_new(j)^XOR_pkt_num;
                if (isSuccess)
                    success_cnt_in_each_pkt_list(:,j) = 0;
                end
            end
        end
    end

    % ---------------------------------- Return ---------------------------------- %

    r =  success_cnt_in_each_pkt_list;%> zeros(1, length(e_new));
end
