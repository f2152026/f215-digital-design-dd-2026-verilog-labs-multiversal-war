module tb;

  reg [1:0] t_A;
  reg [1:0] t_B;

  wire t_GT;
  wire t_LT;
  wire t_EQ;

  integer i;
  integer j;
  integer errors;

  comp2 DUT (
    .A(t_A),
    .B(t_B),
    .GT(t_GT),
    .LT(t_LT),
    .EQ(t_EQ)
  );

  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    errors = 0;

    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_A = i;
        t_B = j;
        #1;

        if (t_GT !== (i > j)) begin
          $display("ERROR: A=%0d B=%0d: GT=%b, expected=%b",
                   i, j, t_GT, (i > j));
          errors = errors + 1;
        end

        if (t_LT !== (i < j)) begin
          $display("ERROR: A=%0d B=%0d: LT=%b, expected=%b",
                   i, j, t_LT, (i < j));
          errors = errors + 1;
        end

        if (t_EQ !== (i == j)) begin
          $display("ERROR: A=%0d B=%0d: EQ=%b, expected=%b",
                   i, j, t_EQ, (i == j));
          errors = errors + 1;
        end

        if ((t_GT + t_LT + t_EQ) !== 1) begin
          $display("ERROR: A=%0d B=%0d: GT=%b LT=%b EQ=%b -- not exactly one is 1",
                   i, j, t_GT, t_LT, t_EQ);
          errors = errors + 1;
        end
      end
    end

    if (errors == 0)
      $display("PASS: All 16 input combinations are correct.");
    else
      $display("FAIL: %0d errors found.", errors);

    $finish;
  end

  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b",
             t_A, t_B, t_GT, t_LT, t_EQ);

endmodule