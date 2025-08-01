% eval_RandONet evaluates a Random projection-based Operator Network (RandONet) model by
% computing the weighted inner product between the trunk and branch networks.
%
% Syntax: G = eval_RandONet_parametric(net, ff, param, yy)
%
% Inputs:
%   - net : Structure containing the parameters of the RandONet model.
%           Fields include:
%             - tr_fT : Trunk network activation function (nonlinear transformation).
%             - tr_fB : Branch network activation function (nonlinear transformation).
%             - alphat, betat : Parameters for input transformation in the trunk network.
%             - alphab, betab : Parameters for input transformation in the branch network.
%             - C : Weight matrix for the inner product.
%   - ff    : Input function for the branch network.
%   - param : Input parameter for the homotopy in the branch
%   - yy    : Input spatial locations for the trunk network.
%
% Output:
%   - G : Output of the RandONet model, computed as the weighted inner product
%         of the trunk and branch networks, i.e., <T, B>_C.
%
% The function transforms the inputs using the trunk and branch networks, and
% computes the result by applying the weight matrix C to the inner product of
% these transformations.
%
% DISCLAIMER: This software is provided "as is" without warranty of any kind.
% This includes, but is not limited to, warranties of merchantability,
% fitness for a particular purpose, and non-infringement.
% The authors and copyright holders are not liable for any claims, damages,
% or other liabilities arising from the use of this software.
%
%Copyright (c) 2024 Gianluca Fabiani
%
%Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.
% You may not use this material for commercial purposes.
% If you remix, transform, or build upon this material,
% you must distribute your contributions under the same license as the original.

function G=eval_RandONet_parametric(net,ff,param,yy)
if net.tr_fT=='tanh'
    tr_fT=@tanh;
end
if net.tr_fB=='lin'
    tr_fB=@(x)x;
elseif net.tr_fB=='cos'
    tr_fB=@cos;
end
ff=[ff;param];
param_rescaled=(param-net.param0)/net.dparam;
Tr=tr_fT(yy*net.alphat+net.betat); %trunk
if ~isfield(net,'flag_norm')==1
    net.flag_norm=0;
end
if ~isfield(net,'n_out')==1
    net.n_out=1;
end
flag_norm=net.flag_norm;
if flag_norm==1
    norm_e=@(e) sqrt(e.^2+(1-e).^2);
else
    norm_e=@(e) 1;
end
Br_train=tr_fB(net.alphab0*ff.*((1-param_rescaled)./norm_e(param_rescaled))+...
    net.alphab1*ff.*((param_rescaled)./norm_e(param_rescaled))+net.betab); %branch
Ny=size(yy,1);
if net.n_out==1
    G=Tr*net.C*Br_train; %weighted inner product of trunk and branch <T,B>_C
elseif net.n_out>1
    Ns=size(ff,2);
    G=zeros(Ny*net.n_out,Ns);
    for jj=1:n_out
        ind=1:Ny+(jj-1)*Ny;
        G(ind,:)=Tr*net.C{jj}*Br_train;
    end
end
%
end