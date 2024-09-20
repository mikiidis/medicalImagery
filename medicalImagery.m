fotoAsal = imread('K2.jpg');
fotoAbu = rgb2gray(fotoAsal);
[counts, idx] = imhist(fotoAbu);
[idx counts]

%imhist(fotoAbu)
%===== catatan, nilai paling rendah = 205 ========

%bikin foto jadi hitam putih
[baris, kolom] = size(fotoAbu);
g = zeros(baris, kolom);
for i = 1:baris
   for j = 1:kolom
       if fotoAbu(i,j) < 205
           g(i,j) = 1;
       end
   end
end
g = logical(g);


%hilangin bolong2
gfill = imfill (g, 'holes');
%imshow(gfill)

%morphology bersihin yang bocor2
se4 = strel('disk', 4);
gfill2 = imopen (gfill, se4);
%imshow(gfill2)

%morphology hilangin yang nyatu
se6 = strel('disk', 6);
gfill3 = imerode(gfill2, se6);
%imshow(gfill3)

%pelabelan cell
[L, num] = bwlabel(gfill3, 4);
%imshow(L)

vislabels(L)

EkstraksiCiri = regionprops('table', L, 'Area', 'Perimeter');
index = find (EkstraksiCiri.Area > 1000 & EkstraksiCiri.Perimeter > 90);

Baru = zeros(size(L));
k = length(index);
for i=1:k
   Baru(L==(index(i)))= 1;
end

%figure, subplot(1,2,1), imshow(L), title('labelled cells'), ...
   %subplot(1,2,2), imshow(Baru), title('selected cells by area')

[L2,num2] = bwlabel(Baru,4);
C = zeros(baris,kolom,3);
for i = 1:baris
   for j =1:kolom
       if L2(i,j)
           C(i,j,:) = fotoAsal(i,j,:);
       end
   end
end
C = uint8(C);

%figure, subplot(1,2,1), imshow(L), title('labelled cells'), ...
   %subplot(1,2,2), imshow(C), title('selected cells by area')

MeanR = regionprops('table',L2,C(:,:,1),'MeanIntensity');
MeanG = regionprops('table',L2,C(:,:,2),'MeanIntensity');
MeanB = regionprops('table',L2,C(:,:,3),'MeanIntensity');

FiturWarna = [MeanR.MeanIntensity MeanG.MeanIntensity MeanB.MeanIntensity];
ShapeDescp = regionprops('table',L2,'Perimeter','Area');
Roundness = ((ShapeDescp.Perimeter).^2)./(4*pi*ShapeDescp.Area);
Ciri = [FiturWarna ShapeDescp.Area ShapeDescp.Perimeter Roundness];


%seleksi berdasar ciri warna dan bentuk
% #catatan sel darah bentuk lingkaran
indeksTrombosit = find(Ciri(:,1) > 200 & Ciri(:,3) > 150 & Ciri(:,6) <= 1);

Baru2 = zeros(baris,kolom);
k = length(indeksTrombosit);
for i=1:k
      Baru2(L2==(indeksTrombosit(i)))= 1;
end
Baru2 = logical(Baru2);

%Bikin tepi/pinggiran
se2 = strel('disk',2);
Melebar2 = imdilate(Baru2,se2);
Tepi3 = xor(Melebar2,Baru2);

D = imOverlay(fotoAsal,Tepi3, [0 0 255]);
[L3, num3] = bwlabel(Baru2,4);

%===============================================
%Buat munculin sel darah yang tidak berbentuk lingkaran
indeksTrombosit2 = find(Ciri(:,1) > 200 & Ciri(:,3) > 150 & Ciri(:,6) > 1);

Baru3 = zeros(baris,kolom);
k = length(indeksTrombosit2);
for i=1:k
      Baru3(L2==(indeksTrombosit2(i)))= 1;
end
Baru3 = logical(Baru3);

%Bikin tepi/pinggiran
Melebar3 = imdilate(Baru3,se2);
Tepi4 = xor(Melebar3,Baru3);

D2 = imOverlay(fotoAsal,Tepi4, [0 0 255]);
[L4, num4] = bwlabel(Baru3,4);

figure, subplot(1,2,1), imshow(D), title('Sel darah Lingkaran'), ...
   subplot(1,2,2), imshow(D2), title('Sel darah bukan Lingkaran')
