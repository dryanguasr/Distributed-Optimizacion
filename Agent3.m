classdef Agent3
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID = 0;
        mu_l = [];         % l_ID distribution mean
        sigma_l = [];      % l_ID distributiod std
        s = 0;             % process observation
        theta = []         % hypothesis
        n = 1;             % number of agents
        m = 1;             % number of hypotheses
        Ldel = 1;          % maximum number of delays
        k = 0;             % Current Self Timer
        ki = [];           % last known update
        od = 0;            % output degrees
        y = 1;             % self weights
        mu = [];           % beliefs
        rho_y = [];        % self weight sent (y)
        rho_mu = [];       % self weight sent (mu)
        rhos_y = [];       % self weight sent verification (y)
        rhos_mu = [];      % self weight sent verification (mu)
        phi_y = 0;         % self weight received (y)
        phi_mu = [];       % self weight received (mu)
        ki_buff = [];      % k messages buffer
        y_buff = [];       % y message buffer
        mu_buff = [];      % beliefs message buffer
        
        ki_F_buff = [];    % k Future messages buffer
        y_F_buff = [];     % y Future message buffer
        mu_F_buff = [];    % beliefs Future message buffer
    end
    
    methods
        function V = Agent3(ID, n, m, mu_l, sigma_l, od, Ldel)
            %AGENT Construct an instance of this class
            %   Detailed explanation goes here
            V.ID = ID;
            V.mu_l = mu_l;
            V.sigma_l = sigma_l;
            V.n = n;
            V.m = m;
            V.Ldel = Ldel;
            V.mu = ones(m,1)/m;
            V.od = od;
            V.y = 1;
            V.k = 0;
            V.rho_y = zeros(n,1);
            V.rhos_y = zeros(n,1);
            V.rho_mu = ones(n,m);
            V.rhos_mu = ones(n,m);
            V.phi_y = 0;
            V.phi_mu = ones(1,m);
            V.ki = zeros(n,1);
            V.y_buff = zeros(n,1);
            V.mu_buff = ones(n,m);
            V.ki_buff = zeros(n,1);
            V.y_F_buff = zeros(n,Ldel);
            V.mu_F_buff = ones(n,m,Ldel);
            V.ki_F_buff = zeros(n,Ldel);
        end
        
        function V = idleBehavior(V)
            for j = 1:V.n
                if(V.ki_F_buff(j,1)>V.ki_buff(j))
                    V.y_buff(j) = V.y_F_buff(j,V.Ldel);
                    V.ki_buff(j) = V.ki_F_buff(j,V.Ldel);
                    V.mu_buff(j,:) = V.mu_F_buff(j,:,V.Ldel);
                end
                for del = 1:V.Ldel-1
                    V.y_F_buff(j,del) = V.y_F_buff(j,del+1);
                    V.ki_F_buff(j,del) = V.ki_F_buff(j,del+1);
                    V.mu_F_buff(j,:,del) = V.mu_F_buff(j,:,del+1);
                end
            end
        end
        
        function V = selfUpdate(V, k, s, od)
            V.s = s;
            V.k = k;
            %V.ki(V.ID) = k;
            V.od = od;
            V.phi_y = V.phi_y + V.y/(od+1);
            for k = 1:V.m
                %V.phi_mu(k) = V.phi_mu(k)*V.mu(k)^(V.y/(od+1));
                V.phi_mu(k) = exp(log(V.phi_mu(k))+log(V.mu(k))*V.y/(od+1));
            end
        end
        
        function V = receiveMessage(V, ID, phi_y, phi_mu, k, delay)
            if(delay>0)
                V.y_F_buff(ID,delay) = phi_y;
                V.mu_F_buff(ID,:,delay) = phi_mu;
                V.ki_F_buff(ID,delay) = k;
            else
                V.y_buff(ID) = phi_y;
                V.mu_buff(ID,:) = phi_mu;
                V.ki_buff(ID) = k;
            end
        end
        
        function V = processMessages(V)
            for j = 1:V.n
                if V.ki_buff(j) > V.ki(j)
                    V.ki(j) = V.ki_buff(j);
                    V.rhos_y(j) = V.y_buff(j);
                    V.rhos_mu(j,:) = V.mu_buff(j,:);
                end
            end
            
            yh = V.y/(V.od+1);
            for j=1:V.n
                if j~=V.ID
                    yh = yh + V.rhos_y(j)-V.rho_y(j);
                end
            end
            Prhos = zeros(1,V.m);
            li = zeros(1,V.m);
            SL = zeros(1,V.m);
            for p = 1:V.m
                li(p) = normpdf(V.s, V.mu_l(p), V.sigma_l(p));
                for j = 1:V.n
                    if j~=V.ID
                        Prhos(p) = Prhos(p)+log(max(exp(-735),V.rhos_mu(j,p)))-log(max(exp(-735),V.rho_mu(j,p)));
                    end
                end
                SL(p) = (1/yh)*(V.y/(V.od+1)*log(max(V.mu(p),exp(-735))) + Prhos(p) + log(max(exp(-735),li(p))));
            end
            if(sum(SL<-735)==V.m)
%                 disp(['Warning too small beliefs at k = ' num2str(V.ki(V.ID))])
%                 disp(['SL = ' num2str(SL)])
                SL = SL-min(SL)-735;
                if(sum(SL>705)>0)
%                     disp('    Difference between values too large (adjusting top)')
                    SL = max(-735,SL-max(SL)+705);
                end
%                 disp(['Repaired SL = ' num2str(SL)])
            end
            
            muu = exp(SL);
            Z = sum(muu);
            
            if(Z == 0 || sum(isnan(muu))~=0)
                disp(['Z = ' num2str(Z)])
                disp(['muu = ' num2str(muu)])
                disp(['Prhos = ' num2str(Prhos)])
                disp(['log(li) = ' num2str(log(li))])
                disp(['mu = ' num2str(V.mu')])
                disp(SL)
                disp(exp(SL))
                
%                disp(['k_buff = ' num2str(V.ki_buff')])
%               disp(['k =      ' num2str(V.ki')])
%                 disp(['y_buff = ' num2str(V.y_buff')])
%                  disp('mu_buff = ')
%                  disp(num2str(V.mu_buff))
%                 disp('rhos_mu - rho_mu = ')
%                 disp(num2str(V.rhos_mu - V.rho_mu))
                disp('rhos_mu = ')
                disp(num2str(V.rhos_mu))
            end
            
            V.mu(:) = muu/Z;
            V.y = yh;
            V.rho_y = V.rhos_y;
            V.rho_mu = V.rhos_mu;
        end
    end
end