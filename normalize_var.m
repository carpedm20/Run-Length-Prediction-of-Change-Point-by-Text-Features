 function normalized = normalize_var(array, x, y)

     m = min(array);
     range = max(array) - m;
     array = (array - m) / range;

     range2 = y - x;
     normalized = (array*range2) + x;