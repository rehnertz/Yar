if (index >= 0 && (prereq < 0 || prereq <= global.trigger_index)) {
    global.trigger_index = index
    on_trigger()
    instance_destroy()
}
