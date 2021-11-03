MEMORY
{
    flash : org = 0x08000000, len = 64k
    ram : org = 0x20000000, len = 8k
}
   
SECTIONS
{
         
    . = ORIGIN(flash);
        .text : {
         
        } > flash
    . = ORIGIN(ram);
        .data : {
                     
        } > ram
}
