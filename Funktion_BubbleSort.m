function A = bubbleSort(A)
%% Bubble Sort Algorithm
% BubbleSort is a simple sorting algorithm that repeatedly steps through the list 
% to be sorted, compares each pair of adjacent items and swaps them if 
% they are in the wrong order. The pass through the list is repeated until 
% no swaps are needed, which indicates that the list is sorted. 
%
% Example: 
%
% consider we want to sort elements in the vector A
% >> A = rand(1,10);
% >> SortedA = bubbleSort(A);
%
% -------------------------------------------------
% code by: Reza Ahmadzadeh (reza.ahmadzadeh@iit.it
% -------------------------------------------------
% Reference: https://en.wikipedia.org/wiki/Bubble_sort
%
%
n = length(A);
while n ~= 0
    nn = 0;
    for ii = 1:n-1
        if A.Sys(ii) > A(ii+1)
            [A(ii+1),A(ii)] = deal(A(ii), A(ii+1));
            nn = ii;
        end
    end
    n = nn;
end
end