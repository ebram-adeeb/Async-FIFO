module FIFO_memory 
#(
    parameter int FIFO_WIDTH = 16,
    parameter int FIFO_DEPTH = 512,
    parameter int ADDRSIZE = $clog2(FIFO_DEPTH)
)
(
    input rst_n,
    input wclk,
    input rclk,
    input winc,
    input rinc,
    input full,
    input empty,
    input [FIFO_WIDTH-1:0]wr_data,
    input [ADDRSIZE-1:0]wr_addr, 
    input [ADDRSIZE-1:0]re_addr,
    output logic [FIFO_WIDTH-1:0]re_data
);
    //memory element
    logic [FIFO_WIDTH-1:0] FIFO_mem [FIFO_DEPTH-1:0];
    
    always_ff @(posedge wclk) begin
        if(winc && ~full) FIFO_mem[wr_addr] <= wr_data;
    end

    always_ff @(posedge rclk) begin
        if(rinc && ~empty) re_data <= FIFO_mem[re_addr];
    end
endmodule