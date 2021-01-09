n = 30;
m = 6;
nack_m = 2;
tx_limit = 3;
err_prob = 0.1;
e = randn(1, n) * 0.01 + err_prob;
total_pkt = 10;
sim_times = 1000000;

tic
fprintf("Averaeg error prob: %f, and std is: %f\n", mean(e), std(e));
% ---------------------------------------------------------------------------- %
%                            Blind Theoretical Value                           %
% ---------------------------------------------------------------------------- %

blind = prod(1 - e.^m)^total_pkt;
blind = blind * sim_times;
fprintf('Theoritical blind success: %f\n', blind);
fprintf('Theoritical blind resource: %f\n', m);

% ---------------------------------------------------------------------------- %
%                               Blind Monte Carlo                              %
% ---------------------------------------------------------------------------- %

suc = 0;
parfor i = 1:sim_times
    tmp_suc = 0;
    for pkt = 1:total_pkt
        e_new = e;

        r = binornd(1, e_new.^m);
        if (~sum(r))
            tmp_suc = tmp_suc + 1;
        end

        % for l = 1:length(r)% 成功的人要從e中踢除
        %     if (r(l) == 0)% success
        %         e_new(l) = 0; %e_new = [e_new 0];
        %     else %Fail
        %         e_new(l) = e(l); % e_new = [e_new e(i)];
        %     end
        % end

        % end
    end
    if (tmp_suc == total_pkt)
        suc = suc + 1;
    end
end
fprintf('Blind Monte Carlo success (Exclude Success UE): %d\n', suc);
fprintf("Blind Monte Carlo resource (Exclude Success UE): %d\n", m*total_pkt);
% ---------------------------------------------------------------------------- %
%                               Nack Monte Carlo                               %
% ---------------------------------------------------------------------------- %

suc = 0;
resource = 0;
parfor i = 1:sim_times
    tmp_suc = 0;
    for pkt = 1:total_pkt
        e_new = e;
        for j = 1:tx_limit
            resource = resource + nack_m;
            r = binornd(1, e_new.^nack_m);
            if (~sum(r))
                tmp_suc = tmp_suc + 1;
                break
            end

            for l = 1:length(r)% 成功的人要從e中踢除
                if (r(l) == 0)% success
                    e_new(l) = 0; %e_new = [e_new 0];
                else %Fail
                    e_new(l) = e(l); % e_new = [e_new e(i)];
                end
            end

        end
    end
    if (tmp_suc == total_pkt)
        suc = suc + 1;
    end
end
fprintf('Nack suc: %d\n', suc);
resource = resource / sim_times;
fprintf("Nack resource: %f\n", resource);

time = toc;
fprintf("Elapsed time: %g\n", time);
