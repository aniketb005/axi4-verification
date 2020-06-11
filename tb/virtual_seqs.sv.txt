class base_virtual_seqs extends uvm_sequence #(uvm_sequence_item);

`uvm_object_utils(base_virtual_seqs)

master_seqr mseqr[];
slave_seqr sseqr[];

tb_config tb_cfg;

virtual_sequencer vseqrh;

extern function new(string name="base_virtual_seqs");
extern task body();
endclass

function base_virtual_seqs::new(string name="base_virtual_seqs");
	super.new(name);
endfunction

task base_virtual_seqs::body();
	
	if(!uvm_config_db #(tb_config)::get(null,get_full_name,"tb_config",tb_cfg))	
	   `uvm_fatal("FATAL","cannot get config in virtual seqs ")
	
	assert($cast(vseqrh,m_sequencer))
	else
	$display("Casting faild in Virtual seqs");

	mseqr = new[tb_cfg.no_of_masters];
	sseqr = new[tb_cfg.no_of_slaves];

	foreach(mseqr[i])
	mseqr[i] = vseqrh.mseqr[i];

	foreach(sseqr[i])
	sseqr[i] = vseqrh.sseqr[i];

endtask

class first_vseq extends base_virtual_seqs;
	
`uvm_object_utils(first_vseq)

first_seq seqh[];
first_slseq sl_seqh[];

extern function new(string name ="first_vseq");
extern task body();
endclass

function first_vseq::new(string name = "first_vseq");
	super.new(name);
endfunction

task first_vseq::body();
	super.body();
	
	seqh = new[tb_cfg.no_of_masters];
	sl_seqh = new[tb_cfg.no_of_slaves];

	foreach(seqh[i])
	begin
	seqh[i] = first_seq::type_id::create($sformatf("seqh[%0d]",i));
	
	//seqh[i].start(mseqr[i]);
	end

	foreach(sl_seqh[i])
	begin
	sl_seqh[i] = first_slseq::type_id::create($sformatf("sl_seqh[%0d]",i));
	fork
	sl_seqh[i].start(sseqr[i]);
        seqh[i].start(mseqr[i]);
	join
end

endtask
