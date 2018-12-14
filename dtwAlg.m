function [matrixD,ix,iy, dOut]=dtwAlg(x,y)
%{
Function for calculating dynamic time warped distance between two vectors

Authors:
Daniel Otero
Jacques Esterhuizen
%}



sizeX = length(x);
sizeY= length(y);

matrixD=zeros(sizeX,sizeY);

matrixD(1,1)=norm(x(1)-y(1));

theBest=zeros(sizeX,sizeY,2);
for i = 1:sizeX
    
    for j=1:sizeY
    
            if i > 1 && j>1
                
                matrixD(i,j)=norm(x(i)-y(j))+min(matrixD(i-1,j),min(matrixD(i,j-1),matrixD(i-1,j-1)));
                
                if matrixD(i-1,j-1) <= min(matrixD(i,j-1),matrixD(i-1,j))
                    
                  theBest(i,j,1)= i-1;
                  theBest(i,j,2)= j-1;
                
                elseif matrixD(i-1,j) <= min(matrixD(i,j-1),matrixD(i-1,j-1))
                    
                  theBest(i,j,1)= i-1;
                  theBest(i,j,2)= j;
                  
                else
                    
                  theBest(i,j,1)= i;
                  theBest(i,j,2)= j-1;
                    
                end
            
            elseif i>1 && j==1
                
                  matrixD(i,j)=norm(x(i)-y(j))+min(matrixD(i-1,j));
                  theBest(i,j,1)= i-1;
                  theBest(i,j,2)= j;
                  
            elseif i==1 && j>1
                
                matrixD(i,j)=norm(x(i)-y(j))+min(matrixD(i,j-1));
                theBest(i,j,1)= i;
                theBest(i,j,2)= j-1;
                
            end
       
    end

end

    i=sizeX;
    j=sizeY;
    ix=zeros(1);
    iy=zeros(1);
    ix(1)=i;
    iy(1)=j;
    ind=1;
    
    while i>1 || j >1
       
        ind=ind+1;
        ix=[ix theBest(i,j,1)];
        iy=[iy theBest(i,j,2)];
        
        ind=ind+1;
        
        i=theBest(i,j,1);
        j=theBest(i,j,2);
        
    end
    
    ix=fliplr(ix);
    iy=fliplr(iy);
    dOut = matrixD(sizeX,sizeY); 
%     figure
%     subplot(2,1,1);
%     hold all
%     for i = 1:sizeX
%         for j=1:sizeY
%             scatter(i,x(theBest(i, j,1)))
%         end
%     end
%     plot(sizeX,x);
%     plot(sizeY,y);
%     grid;
%     legend('signal 1','signal 2');
%     title('Original signals');
%     
%     subplot(2,1,2);
%     hold all
%     plot(x(ix));
%     plot(y(iy));
%     grid;
%     legend('signal 1','signal 2');
%     title('Warped signals');

    
       
end