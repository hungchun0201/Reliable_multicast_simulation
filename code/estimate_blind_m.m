function blind_trans_time = estimate_blind_m(e,rel_constraint,blind_upper_bound,total_pkt)
blind_trans_time = 0;
    for i = 1:blind_upper_bound
        blind_trans_time = i;
        if((prod(1.-e.^i))^total_pkt>=rel_constraint)
            break
        end
    end
end