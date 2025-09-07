function uu=time_stepper(fun,u0,Nt,flag,Nxinterp)
if nargin<4
    flag=0;
end
uu(:,1)=u0;

for i=2:Nt
    uu(:,i)=fun(uu(:,i-1));
   %FD corrections of the boundary conditions
    %uu(1,i)=(4*uu(2,i)-uu(3,i))/3;
    %uu(end,i)=(4*uu(end-1,i)-uu(end-2))/3;
    uu(1,i)=0; %uu(1,i)*0.99+(4*uu(2,i)-uu(3,i))/3*0.01;
    uu(end,i)=0; %uu(end,i)*0.99+(4*uu(end-1,i)-uu(end-2))/3*0.01;
end
if flag==1
    uu=uu(:,end);
end

end
