module reptr_empty 
#(
    parameter int FIFO_DEPTH = 512,
    parameter int ADDRSIZE = $clog2(FIFO_DEPTH)
)
(
    input  rclk, 
    input  rst_n, 
    input  rinc,
    input  [ADDRSIZE:0] wr_ptr,  
    output logic [ADDRSIZE-1:0] re_addr, 
    output logic [ADDRSIZE-1:0] re_addrnext,
    output logic [ADDRSIZE:0] re_ptr, 
    output logic empty
);
    logic [ADDRSIZE:0] re_bin;
    wire  [ADDRSIZE:0] re_greynext,re_binnext;
    //read_ptr synchronization 
    logic [ADDRSIZE:0] wr_ptr1, wr_ptr2;
    always_ff @(posedge rclk or negedge rst_n) begin 
        if(~rst_n) {wr_ptr1,wr_ptr2} <= 0;
        else {wr_ptr1,wr_ptr2} <= {wr_ptr,wr_ptr1};
    end
    //Pointer state
    always_ff @(posedge rclk or negedge rst_n) begin
        if(!rst_n) {re_bin, re_ptr} <= 0;
        else {re_bin, re_ptr} <= {re_binnext,re_greynext};
    end
    //Point count logic
    assign re_addr      = re_bin[ADDRSIZE-1:0];
    assign re_addrnext  = re_binnext[ADDRSIZE-1:0];
    assign re_binnext   = re_bin + (rinc & ~empty);
    assign re_greynext  = re_binnext ^ (re_binnext>>1); 
    //Full logic
    wire empty_int; 
    assign empty_int = (wr_ptr2 == re_greynext);
    always_ff @(posedge rclk or negedge rst_n) begin
        if(~rst_n) empty <= 1'b1;
        else empty <= empty_int;
    end
endmodule