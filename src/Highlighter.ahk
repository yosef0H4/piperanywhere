#Requires AutoHotkey v2

class Highlighter {
    static guis := []

    static Highlight(x?, y?, w?, h?, showTime:=0, color:="Red", d:=2) {
        if !IsSet(x) {
            for _, r in this.guis
                r.Destroy()
            this.guis := []
            return
        }

        if !this.guis.Length {
            Loop 4
                this.guis.Push(Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"))
        }

        Loop 4 {
            i := A_Index
            x1 := (i=2 ? x+w : x-d)
            y1 := (i=3 ? y+h : y-d)
            w1 := (i=1 or i=3 ? w+2*d : d)
            h1 := (i=2 or i=4 ? h+2*d : d)
            this.guis[i].BackColor := color
            this.guis[i].Show("NA x" . x1 . " y" . y1 . " w" . w1 . " h" . h1)
        }

        if showTime > 0 {
            Sleep(showTime)
            this.Highlight()
        } else if showTime < 0
            SetTimer(() => this.Highlight(), -Abs(showTime))
    }
} 