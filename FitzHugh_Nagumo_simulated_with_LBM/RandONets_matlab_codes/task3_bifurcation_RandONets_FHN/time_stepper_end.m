function uu=time_stepper_end(fun,u0,Nt)
uu(:,1)=u0;

for i=2:Nt
    uu(:,i)=fun(uu(:,i-1));
   %FD corrections of the boundary conditions
    uu(1,i)=(4*uu(2,i)-uu(3,i))/3;
    uu(end,i)=(4*uu(end-1,i)-uu(end-2,i))/3;
    %
    uu(end/2+1,i)=(4*uu(end/2+2,i)-uu(end/2+3,i))/3;
    uu(end/2,i)=(4*uu(end/2-1,i)-uu(end/2-2,i))/3;
    %uu(1,i)=uu(1,i)*0.99+(4*uu(2,i)-uu(3,i))/3*0.01;
    %uu(end,i)=uu(end,i)*0.99+(4*uu(end-1,i)-uu(end-2))/3*0.01;
end
uu=uu(:,end);
end