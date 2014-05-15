package ece351.w.ast;

import org.parboiled.common.ImmutableList;

import ece351.util.Debug;
import ece351.util.Examinable;
import ece351.util.Examiner;


public final class WProgram implements Examinable {
	public final ImmutableList<Waveform> waveforms;

	/**
	 * Constructs a WProgram with a list of waveforms given by parameter
	 * waveforms
	 * 
	 * @param waveforms
	 */
	public WProgram(final ImmutableList<Waveform> waveforms) {
		this.waveforms = waveforms;
	}
	
	/**
	 * Constructs a WProgram with a empty list of waveforms
	 */
	public WProgram() {
		this.waveforms = ImmutableList.of();
	}

	public boolean repOk() {
		if (waveforms == null) return false;
		for (final Waveform w : waveforms) {
			if (!w.repOk()) return false;
		}
		return true;
	}
	
	public int timeCount() {
		int timeCount = 0;
		for (final Waveform w : waveforms) {
			if (timeCount == 0) {
				timeCount = w.bits.size();
			}
			assert w.bits.size() == timeCount : "inconsistent waveform sizes";
		}
		return timeCount;
	}
	
	public boolean isDefinedAtTime(final String var, final int time) {
		return waveformAtTime(var, time).equals("U");
	}
	
	public boolean valueAtTime(final String var, final int time) {
		return waveformAtTime(var, time).equals("1");
	}

	/**
	 * Lookup the value of the named waveform at the named time.
	 * @param var
	 * @param time
	 * @throws IllegalArgumentException if the named waveform or the named time does not exist.
	 * @return
	 */
	public String waveformAtTime(final String var, final int time) {
		final Waveform w = waveform(var);
		if (w == null) {
			throw new IllegalArgumentException("variable is not defined in W program: " + var);
		}
		if (time >= w.bits.size()) {
			throw new IllegalArgumentException("variable is not defined at given time: " + var + " " + time);
		}
		return w.bits.get(time);
	}
	
	public Waveform waveform(final String var) {
		for (final Waveform w : waveforms) {
			if (w.name.equals(var)) return w;
		}
		// didn't find a match, let's give some debugging output
		final StringBuffer b = new StringBuffer();
		b.append("Couldn't find a match for signal named '");
		b.append(var);
		b.append("' in W file with signals: ");
		for (final Waveform w : waveforms) {
			b.append(w.name);
			b.append(", ");
		}
		Debug.barf(b.toString());
		// return normally if we are not in debug mode
		return null;
	}
	
	/**
	 * Construct a new WProgram with all of this WProgram's waveforms plus the parameter.
	 * 
	 * @param waveform the waveform to append
	 * @return Returns a new WProgram object with parameter waveform attached to the
	 *         original WProgram
	 */
	public WProgram append(final Waveform waveform) {
		return new WProgram(waveforms.append(waveform));
	}
	
	@Override
	public String toString() {
// TODO: 6 lines snipped
throw new ece351.util.Todo351Exception();
	}

	/**
	 * If we override equals() then we must override hashCode().
	 */
	@Override
	public int hashCode() {
		return waveforms.hashCode();
	}
	

	/** 
	 * WProgram objects are immutable. Order matters. 
	 */
	@Override
	public boolean equals(final Object obj) {
		// basics
		if (obj == null) return false;
		if (obj == this) return true;
		if (!obj.getClass().equals(this.getClass())) return false;
		final WProgram other = (WProgram) obj;
		assert repOk();
		assert other.repOk();
		// compare state
		return waveforms.equals(other.waveforms);
	}
	
	/** 
	 * Order doesn't matter. 
	 */
	@Override
	public boolean isomorphic(final Examinable obj) {
		// basics
		if (obj == null) return false;
		if (obj == this) return true;
		if (!obj.getClass().equals(this.getClass())) return false;
		final WProgram other = (WProgram) obj;
		assert repOk();
		assert other.repOk();
		// compare state, without regard to order
		return Examiner.unorderedExamination(Examiner.Isomorphic, this.waveforms, other.waveforms);
	}

	/** 
	 * Define in terms of isomorphic. 
	 */
	@Override
	public boolean equivalent(final Examinable obj) {
		return isomorphic(obj);
	}

}
