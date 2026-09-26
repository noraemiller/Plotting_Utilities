function prismplot_withlines(Y,color,x,opt,dotson,bar)
%this function can plot data comparing within 1 group i.e. either ttest or
%1way ANOVA statistical comparisons


if nargin<2 || isempty(color)
color2=cell(1,length(Y));
color=color2;
colorflag=1;
else
    colorflag=0;
end
        if ~iscell(Y)
    Y=mat2cell(Y,size(Y,1),ones(1,size(Y,2)));
        end

if nargin<3 || isempty(x)
    x=1:length(Y);
end
if nargin<5 || isempty(dotson)
    dotson=true;
end

if nargin<6 || isempty(bar)
    bar=true;
end
dotX = nan(size(Y{1},1),size(Y,2));
dotY = nan(size(Y{1},1),size(Y,2));

for n=1:length(Y)
if nargin<2 || colorflag
    color2{n}=1-([1 1 1]/(length(Y))*n);
    color{n}=color2{n};
end
if ~iscell(color)
    color2{n}=color;
else
    color2{n}=color{n};
end
% X=X(:)';
% X{n}=n;
if nargin<4
    ys{n}=(nanstd(Y{n}))./sqrt(sum(~isnan(Y{n})));
elseif opt==1
    ys{n}=(nanstd(Y{n}));
else
        ys{n}=(nanstd(Y{n}))./sqrt(sum(~isnan(Y{n})));
end
Ymean{n}=nanmean(Y{n});

if bar
    plot([x(n)-.2 x(n)+.2],[Ymean{n}-ys{n} Ymean{n}-ys{n}],'-','Color','k','LineWidth',2)
    hold on
    plot([x(n) x(n)],[Ymean{n}-ys{n} Ymean{n}+ys{n}],'-','Color','k','LineWidth',2)
    plot([x(n)-.2 x(n)+.2],[Ymean{n}+ys{n} Ymean{n}+ys{n}],'-','Color','k','LineWidth',2)
    plot(polyshape([x(n)-.4 x(n)-.4 x(n)+.4 x(n)+.4],[Ymean{n} 0 0 Ymean{n}]),'FaceColor',color2{n},'EdgeColor','k','LineWidth',2)
else
    plot([x(n)-.2 x(n)+.2],[Ymean{n}-ys{n} Ymean{n}-ys{n}],'-','Color',color2{n},'LineWidth',2)
    hold on
    plot([x(n) x(n)],[Ymean{n}-ys{n} Ymean{n}+ys{n}],'-','Color',color2{n},'LineWidth',2)
    plot([x(n)-.2 x(n)+.2],[Ymean{n}+ys{n} Ymean{n}+ys{n}],'-','Color',color2{n},'LineWidth',2)
    plot([x(n)-.4 x(n)+.4],[Ymean{n} Ymean{n}],'-','Color',color2{n},'LineWidth',2)
end
if dotson
[xValues,Ynew]=scatter_points_even(sort(Y{n}(:)));
plot(xValues+x(n)-1,Ynew,'o','MarkerFaceColor',color2{n},'MarkerSize',15,'MarkerEdgeColor','k','LineWidth',2)
dotX(:,n)=xValues+x(n)-1;
dotY(:,n)=Ynew;
end
end
for i=1:size(dotX,1)
    for j=1:size(dotX,2)-1
        p = plot([dotX(i,j) dotX(i,j+1)],[dotY(i,j) dotY(i,j+1)],'-','Color','k','LineWidth',2);
        uistack(p,'bottom')
    end    
end    

plot(xlim,[0 0],'--','Color','k','LineWidth',2)

if size(Y,2)==2
    [h,p]=ttest([dotY(:,1) dotY(:,2)]);
    if h==1
        plot([dotX(1,1) dotX(1,2)],[max(dotY,[],'all')*1.1 max(dotY,[],'all')*1.1],'-','Color','k','LineWidth',2)
        if p < 0.01
            stars = '**';
        elseif p < 0.001
            stars = '***';
        else
            stars = '*';
        end    
        text((dotX(1,1)+dotX(1,2))/2,max(dotY,[],'all')*1.11,stars,'FontSize',30)
    end
elseif size(Y,2)>2
    [p,tbl,stats]=anova1(dotY,[],'off');
    results = multcompare(stats,'Display','off');
    results_small = results(:,[1,2,6]);
    sig_count = sum(results_small(:,3)<= 0.05);
    sig_comps = results_small(:,results_small(:,3)<= 0.05);
    for i=1:sig_count
        x1 = sig_comps(i,1);
        x2 = sig_comps(i,2);
        plot([dotX(1,x1) dotX(1,x2)],[max(dotY,[],'all')*(1+0.1*i) max(dotY,[],'all')*(1+0.1*i)],'-','Color','k','LineWidth',2)
        if sig_comps(i,3) < 0.01
            stars = '**';
        elseif sig_comps(i,3) < 0.001
            stars = '***';
        else
            stars = '*';
        end    
        text((dotX(1,x1)+dotX(1,x2))/2,max(dotY,[],'all')*(1.01+0.1*i),stars,'FontSize',30)
    end    
end

set(gca,'XTick',[])