#Requires AutoHotkey v2

class Rectangle_creator {
    ; Initialize global variables
    coord_1 := [0,0]
    coord_2 := [0,0]
    isFirstCoord := true
    isBoxActive := false
    g_CurrentText := ""
    rectangle := [0,0,0,0]

    get_coord() {
        MouseGetPos(&x, &y)
        return [x, y]
    }

    set_first_coord() {
        this.coord_1 := this.get_coord()
        return this.coord_1
    }

    set_second_coord() {
        this.coord_2 := this.get_coord()
        return this.coord_2
    }

    set_rectangle() {
        this.rectangle := [
            Min(this.coord_1[1], this.coord_2[1]), 
            Min(this.coord_1[2], this.coord_2[2]), 
            Abs(this.coord_2[1] - this.coord_1[1]), 
            Abs(this.coord_2[2] - this.coord_1[2])
        ]
        return this.rectangle
    }
} 