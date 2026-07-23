module wrptr_full 
#(
    parameter int FIFO_DEPTH = 512,
    parameter int ADDRSIZE = $clog2(FIFO_DEPTH)
)
(
    input  wclk, 
    input  rst_n, 
    input  winc,
    input  [ADDRSIZE:0] re_ptr,  
    output logic [ADDRSIZE-1:0] wr_addr, 
    output logic [ADDRSIZE:0] wr_ptr, 
    output logic full
);
    logic [ADDRSIZE:0] wr_bin;
    wire  [ADDRSIZE:0] wr_greynext,wr_binnext;
    //read_ptr synchronization 
    logic [ADDRSIZE:0] re_ptr1, re_ptr2;
    always_ff @(posedge wclk or negedge rst_n) begin 
        if(~rst_n) {re_ptr1,re_ptr2} <= 0;
        else {re_ptr1,re_ptr2} <= {re_ptr,re_ptr1};
    end
    //Pointer state
    always_ff @(posedge wclk or negedge rst_n) begin
        if(!rst_n) {wr_bin, wr_ptr} <= 0;
        else {wr_bin, wr_ptr} <= {wr_binnext,wr_greynext};
    end
    //Point count logic
    assign wr_addr     = wr_bin[ADDRSIZE-1:0];
    assign wr_binnext  = wr_bin + (winc & ~full);
    assign wr_greynext = wr_binnext ^ (wr_binnext>>1); 
    //Full logic
    wire full_int; 
    assign full_int = ( {2'b11^re_ptr2[ADDRSIZE:ADDRSIZE-1],
                        re_ptr2[ADDRSIZE-2:0] } == wr_greynext);
    always_ff @(posedge wclk or negedge rst_n) begin
        if(~rst_n) full <= 1'b0;
        else full <= full_int;
    end
endmodule