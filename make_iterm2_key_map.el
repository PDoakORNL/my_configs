(require 'cl-lib)
    (message (string-join
              (cl-loop for hex from #x61 to #x7a
                       for char from ?a to ?z
                       collect (format "\"0x%X-0x100000\":{\"Text\":\"[1;P%c\", \"Action\":10}" hex char))
                       ",\n"

))
