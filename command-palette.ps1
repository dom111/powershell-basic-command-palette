# args
Param (
    [switch] $h,
    [switch] $keepOpen
);

# TODO: add config file for these
# styles
$normalBg = "Black";
$normalFg = "White";
$selectedBg = $normalFg;
$selectedFg = $normalBg;

# templates
$prefix = "   ";            # shown before unselected options
$suffix = "   ";            #   "   after      "        "
$prefixSelected = " * ";    #   "   before selected     "
$suffixSelected = "   ";    #   "   after      "        "
$searchPrefix = " | ";      #   "   before the filter
$searchSuffix = "   ";      #   "   after   "    "
$truncateEllipsis = "...";  #   "     "   truncated text
# 

# args
$action = "echo";             # action to run when enter is pressed on list
# 

function Usage {
    Write-Host "usage: command-palette [-k] [<action>] `"<list items>`"";
    Write-Host "  -k      Keep command-palette open after running <action>";
    exit;
};

if ($h) {
    Usage;
};

# if we have multiple arguments, assume that the first is the action
if ($args.Length -gt 1) {
    $action = $args[0];
    $args = $args[1 .. ($args.Length - 1)];
}

# vars
$cols = [System.Console]::WindowWidth;
$lines = [System.Console]::WindowHeight;
$filter = "";
$data = @();

Foreach ($arg in $args) {
    $data += $arg.Split("`n");
}

$filteredData = $data;
$index = 0;

function Filter-Data {
    $filterGlob = $filter.ToCharArray() -join "*";
    $filteredData = @();

    Foreach ($item in $data) {
        if ($item -like "*$filterGlob*") {
            $filteredData += $item;
        }
    }

    if ($index -gt $filteredData.Length) {
        $index = $filteredData.Length - 1;
    }

    if ($index -lt 0) {
        $index = 0;
    }

    return $filteredData;
    # TODO: sort data ascending by length of match
};

function Update-Display {
    $cols = [System.Console]::WindowWidth;
    $lines = [System.Console]::WindowHeight;
    $lineCounter = $lines;

    [System.Console]::CursorTop = 0;
    $filterString = "$searchPrefix$filter$searchSuffix";
    $lineCounter--;
    $endOfLine = " " * ($cols - ($filterString.Length + 1));

    Write-Host $filterString -NoNewline;
    Write-Host $endOfLine;

    $dataToRender = $filteredData;
    $maxLines = $lines - 3;
    $i = 0;

    if ($dataToRender.Length -gt $maxLines) {
        $startIndex = $index - [Math]::floor($maxLines / 2) - 1;

        if ($startIndex -lt 0) {
            $startIndex = 0;
        }

        $endIndex = $startIndex + $maxLines;

        if ($endIndex -gt $filteredData.Length) {
            $endIndex = $filteredData.Length - 1;
        }

        $dataToRender = @();
        $i = $startIndex;

        while ($i -le $endIndex) {
            $dataToRender[$i] += $filteredData[$i];
            $i++;
        }
    }

    $i = 0;
    Foreach ($item in $dataToRender) {
        $displayLine = $item;

        if ($i -eq $index) {
            $maxLength = $cols - $prefixSelected.Length - $suffixSelected.Length - $truncateEllipsis.Length;
        }
        else {
            $maxLength = $cols - $prefix.Length - $suffix.Length - $truncateEllipsis.Length;
        }

        if ($displayLine.Length -gt $maxLength) {
            $displayLine = $displayLine.Substring(0, $maxLength) + $truncateEllipsis;
        }

        $endOfLine = " " * ($cols - ("$prefixSelected$displayLine$suffixSelected".Length + 1));

        if ($i -eq $index) {
            Write-Host "$prefixSelected$displayLine$suffixSelected" -NoNewline -ForegroundColor $selectedFg -BackgroundColor $selectedBg;
            Write-Host $endOfLine;
        }
        else {
            Write-Host "$prefix$displayLine$suffix$endOfLine" -ForegroundColor $normalFg -BackgroundColor $normalBg;
        }

        $lineCounter--;
        $i++;
    }

    while (--$lineCounter -gt 0) {
        $endOfLine = " " * ($cols - 1);
        Write-Host $endOfLine;
    }
};

function cleanup {
    # tput rmcup;
    # tput cnorm;
};

# main
# tput smcup;
# tput civis;
# trap cleanup EXIT;

Update-Display;

while ($key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")) {
    # TODO
    # left/right +/- screen width / 2
    switch ($key.VirtualKeyCode) {
        8 {
            if ($filter.Length -gt 0) {
                if (($key.ControlKeyState -match "LeftAltPressed") -or ($key.ControlKeyState -match "RightAltPressed")) {
                    $filter = "";
                }
                else {
                    if ($filter.Length -gt 0) {
                        $filter = $filter.Substring(0, $filter.Length - 1);
                    }
                }

                $filteredData = Filter-Data;
                Update-Display;
            }
        }
        13 {
            if ($keepOpen) {
                Invoke-Expression ("$action " + $filteredData[$index]);
                Update-Display;
            }
            else {
                Invoke-Expression ("$action " + $filteredData[$index]);
                exit;
            }
        }
        27 {
            exit;
        }
        33 {
            if ($index -gt 0) {
                $index = $index - [Math]::floor($lines / 2);

                if ($index -lt 0) {
                    $index = 0;
                }

                Update-Display;
            }
        }
        34 {
            if ($index -lt ($filteredData.Length - 1)) {
                $index = $index + [Math]::floor($lines / 2);

                if ($index -gt ($filteredData.Length - 1)) {
                    $index = ($filteredData.Length - 1);
                }

                Update-Display;
            }
        }
        37 {
            # do nothing
        }
        38 {
            if ($index -gt 0) {
                $index--;

                if ($index -lt 0) {
                    $index = 0;
                }

                Update-Display;
            }
        }
        39 {
            # do nothing
        }
        40 {
            if ($index -lt ($filteredData.Length - 1)) {
                $index++;

                if ($index -gt ($filteredData.Length - 1)) {
                    $index = ($filteredData.Length - 1);
                }

                Update-Display;
            }
        }
        default {
            $filter += $key.Character;
            $filteredData = Filter-Data;
            Update-Display;
        }
    }
}
