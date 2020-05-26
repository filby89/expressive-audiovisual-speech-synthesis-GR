function scatterPlot2DShape(coords,varargin)
% show the shape

if nargin<1, error('You did not provide the point coords'); end

[point_num, LineStyle, LineWidth, Color, ...
  Marker, MarkerSize, MarkerEdgeColor, varargin] = process_options(varargin, ...
  'point_num',false, ...
  'LineStyle','none','LineWidth',1,'Color','b', ...
  'Marker','x','MarkerSize',5,'MarkerEdgeColor','b');

[draw_tri, TriLineStyle, TriLineWidth, TriColor] = process_options(varargin,...
  'draw_tri',true, ...
  'TriLineStyle','-','TriLineWidth',1,'TriColor','b');

plot_args = {'LineStyle',LineStyle,'LineWidth',LineWidth,'Color',Color,...
  'Marker',Marker,'MarkerSize',MarkerSize,'MarkerEdgeColor',MarkerEdgeColor};

plot(coords(:,1),coords(:,2),plot_args{:});
axis ij, axis equal; axis off;

holdFlag = ishold; hold on;

if point_num
  % write the number of each point on the graph
  m = size(coords,1);
  for j=1:m, text(coords(j,1),coords(j,2),num2str(j)); end
end

if draw_tri,
  tri = delaunay(coords(:,1),coords(:,2));
  % Plot the Delaunay Triangulation
  delaunay_args = {'LineStyle',TriLineStyle, ...
    'LineWidth',TriLineWidth,'Color',TriColor};
  triplot(tri,coords(:,1),coords(:,2),delaunay_args{:});
end
    
if ~holdFlag, hold off; end