newImage = ~exist('I0');
if newImage I0=imread('../s01m.jpg'); end
vert=[0 0; 0 1;1 1; 1 0]'; % all the image plane
tri=[0 1 2; 2 3 0]';

mmin=0.1; mmax=0.8;
nmin=0.3; nmax=0.65;
text=[mmin nmin; mmin nmax;mmax nmax; mmax nmin]';

if newImage
  J=textureMapMex(text+0.1*randn(size(text)),[100 60 3],I0,vert,tri);
else
  J=textureMapMex(text+0.1*randn(size(text)),[100 60 3]);
end
close;
imshow(J);
drawnow;