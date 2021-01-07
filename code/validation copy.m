n = 30;
m = 6;
nack_m = 2;
tx_limit = 3;
err_prob = 0.1;
sim_times = 10000000;
e = randn(1,n)*0.01 + err_prob;
tic
fprintf("Averaeg error prob: %f, and std is: %f\n",mean(e),std(e));

N = 20;
x = 1:N;
x = x(~(rem(N, x)));

% ---------------------------------------------------------------------------- %
%                            Blind Theoretical Value                           %
% ---------------------------------------------------------------------------- %


blind = prod(1 - e.^m);
blind = blind * sim_times;
fprintf('Theoritical blind success: %f\n', blind);
fprintf('Theoritical blind resource: %f\n', m);

% ---------------------------------------------------------------------------- %
%                               Blind Monte Carlo                              %
% ---------------------------------------------------------------------------- %


for fact = 1:length(x)
    suc = 0;
    fact = x(fact);
    parfor i = 1:sim_times
        e_new = e;
        for j = 1:N/fact
            r = binornd(1, e_new.^fact);
            if (~sum(r))
                suc = suc + 1;
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
    fprintf("Blind Monte Carlo success, m = %d, round = %d: %d\n", fact, N/fact, suc);
    % fprintf("Blind Monte Carlo resource, m = %d, round = %d: %f\n", fact, N/fact, N);
end
% ---------------------------------------------------------------------------- %
%                               Nack Monte Carlo                               %
% ---------------------------------------------------------------------------- %

% suc = 0;
% resource = 0;
% parfor i = 1:sim_times
%     e_new = e;
%     for j = 1:tx_limit
%         resource = resource+nack_m;
%         r = binornd(1, e_new.^nack_m);
%         if (~sum(r))
%             suc = suc + 1;
%             break
%         end

%         for l = 1:length(r)% 成功的人要從e中踢除
%             if (r(l) == 0)% success
%                 e_new(l) = 0; %e_new = [e_new 0];
%             else %Fail
%                 e_new(l) = e(l); % e_new = [e_new e(i)];
%             end
%         end

%     end
% end
% fprintf('Nack suc: %d\n', suc);
% resource = resource/sim_times;
% fprintf("Nack resource: %f\n",resource);

time = toc;
fprintf("Elapsed time: %g\n",time);