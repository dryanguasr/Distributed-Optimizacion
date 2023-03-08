classdef Agent
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ID = 0;
        x = []; % state variable
        y = 1;  % 
        z = 0;
        phix = 0;
        phiy = 0;
        rhox = [];
        rhoy = [];
        k = [];
        do = 0;
        m_buffer = [];
    end
    
    methods
        function obj = Agent(ID, n, x0, do)
            %AGENT Construct an instance of this class
            %   Detailed explanation goes here
            obj.ID = ID;
            obj.x = x0;
            obj.rhox = zeros(1,n);
            obj.rhoy = zeros(1,n);
            obj.k = zeros(1,n);
            obj.do = do;
            obj.m_buffer = zeros(n,2);
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

