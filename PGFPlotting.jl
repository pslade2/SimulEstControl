# Take the data from ParseData and make a variety of plots --> these will be auto passed
data_folder = "general_mod"
folder = "0.25"#"test2"# give data folder name to compute averages from
pdata = " processed data"
tot_dir = "total rewards"
plot_folder = "plots"
sim_types = 3 # number of different sims to plot for profiles
using PGFPlots
using DataFrames
pushPGFPlotsPreamble("\\usepackage{xfrac}")
## ADD A SECOND TRIAL OF THE MPC SETTINGS AND RUN FOR VARYING AND SEE IF IT STILL PLOTS FINE


# make sure all data for the specific plot you want is in the processed data folder specified
# For profile: make sure only plots are for 1 setting of Process and param Noise
# For varying: make sure only the 1 fixed variable is found in this folder

# maybe add function to detect which sets of data are present and determine which of them should be plotted

# run this and identify which of the 3 plot types you would like to make
# set this to determine what plots should be made
vary = false # plot varying process or param noise
varyMass = false # false if fixing mass and varying Process, true if varying mass
profile = true # plot the profile of the results

# general variables for plot labeling
mpc_fobs_leg = "MPC Full Obs"
mpc_unk_leg = "MPC"
mcts_pos_leg = "MCTS Position"
mcts_rand_leg = "MCTS Random"
mcts_smooth_leg = "MCTS Smooth"
qmdp_leg = "QMDP"
nn_leg = "NN"
dnn_leg = "DNN"
adapt_leg = "Adaptive"
# ADD HERE

mcts_pos_style = "blue"
mcts_rand_style = "red"
mcts_smooth_style = "purple"
mpc_fobs_style = "green"
mpc_unk_style = "orange"
qmdp_style = "blue"
nn_style = "grey"
dnn_style = "magenta"
adapt_style = "brown"

mcts_pos = Float64[]
mcts_rand = Float64[]
mcts_smooth = Float64[]
mpc_fobs = Float64[]
mpc_unk = Float64[]
qmdp = Float64[]
nn = Float64[]
dnn = Float64[]
adapt = Float64[]

sim_leg_list = (mcts_pos_leg, mcts_rand_leg, mcts_smooth_leg, mpc_fobs_leg, mpc_unk_leg, qmdp_leg, nn_leg, dnn_leg, adapt_leg)
sim_style_list = (mcts_pos_style, mcts_rand_style, mcts_smooth_style, mpc_fobs_style, mpc_unk_style, qmdp_style, nn_style, dnn_style, adapt_style)


col5 = "black"
mark1 = "none"

cd("data")
cd(join([folder pdata]))

# total reward plot for varying process or parameter noise
#
if vary
  cd(tot_dir)
  tot_files = readdir() # all the files in tot_dir
  # loop through files and construct an array of the points and stdError to plot
  # ADD HERE
  tempName = split(tot_files[1])
  for i = 1:length(tot_files)
    curFile = tot_files[i]
    curData = readtable(curFile)
    curVec = Array(curData[1,:]) # array that I can use
    curName = split(curFile) # get words
    # initialize the arrays that we will plot
    sim = curName[4]
    rollout = curName[5]
    if sim == "mcts" # add to the array of mcts to plot
      if rollout == "position"
        mcts_pos = vcat(mcts_pos,curVec)
        #@show size(mcts_pos)
      elseif rollout == "random"
        mcts_rand = vcat(mcts_rand,curVec)
      elseif rollout == "smooth"
        mcts_smooth = vcat(mcts_smooth,curVec)
      end
    elseif sim == "mpc"
      if rollout == "fobs"
        mpc_fobs = vcat(mpc_fobs, curVec)
      elseif rollout == "unk"
        mpc_unk = vcat(mpc_unk, curVec)
      end
    elseif sim == "qmdp"
      qmdp = vcat(qmdp, curVec)
    elseif sim == "nn"
      nn = vcat(nn,curVec)
    elseif sim == "dnn"
      dnn = vcat(dnn,curVec)
    elseif sim == "adapt"
      adapt = vcat(adapt,curVec)
    end # ADD HERE
    #@show mcts_pos
  end
  # go to plots directory
  cd("../..") # in data
  try mkdir(plot_folder)
  end
  cd(plot_folder) # in plots
  xaxis = L"Process Noise ($\sigma$)"
  yaxis = "Total Reward"
  vertspace = "0.0"
  horizspace = "0.5"
  if varyMass
    vv = 4
    title_start = "PRMV" # Param Varying start of plot name
  else
    vv = 3 # make 3 to plot for varying process, set to 4 for varyingParamNoise
    title_start = "PV" # Process varying start of plot name
  end
    #@show mcts_pos[:,vv]
  # tuple of all possible sims
  #@show tempName
  # check if the arrays for all the floats are filled with data and add to the plotting lists accordingly

  # have to define sim_list after the data has been stored in the arrays
  sim_list = (mcts_pos, mcts_rand, mcts_smooth, mpc_fobs, mpc_unk, qmdp, nn, dnn, adapt) # ADD HERE
  varyPlot_list = PGFPlots.Plots.Linear[] # start blank and add for each possible sim with values
  for i in 1:length(sim_list)
    if length(sim_list[i]) != 0
      cp = Plots.Linear(sim_list[i][:,vv],sim_list[i][:,1], errorBars = ErrorBars(y=sim_list[i][:,2]),style=sim_style_list[i],  mark=mark1, legendentry = sim_leg_list[i])
      append!(varyPlot_list, [cp]) # should end up with a list of
    end
  end

  varyProcessPlot = Axis(varyPlot_list# comment out lines below if that sim type is not going to be plotted
      #Plots.Linear(mcts_pos[:,vv],mcts_pos[:,1], errorBars = ErrorBars(y=mcts_pos[:,2]),style=mcts_pos_style,  mark=mark1, legendentry = mcts_pos_leg)
      #Plots.Linear(mcts_rand[:,vv],mcts_rand[:,1], errorBars = ErrorBars(y=mcts_rand[:,2]),style=mcts_pos_style,  mark=mark1, legendentry = mcts_rand_leg)
      #Plots.Linear(mcts_rand[:,vv],mcts_rand[:,1], errorBars = ErrorBars(y=mcts_rand[:,2]),style=mcts_pos_style,  mark=mark1, legendentry = mcts_rand_leg)
      #Plots.Linear(mcts_smooth[:,vv],mcts_smooth[:,1], errorBars = ErrorBars(y=mcts_smooth[:,2]),style=col4,  mark=mark1, legendentry = mcts_smooth_leg)
      #Plots.Linear(qmdp[:,vv],qmdp[:,vv], errorBars = ErrorBars(y=qmdp[:,vv]),style=col5,  mark=mark1, legendentry = qmdp_leg)
      ,xmode="log",xlabel = xaxis,ylabel=yaxis,legendPos="south west")
  title1 = join([title_start," TR ", tempName[3], " PN ", tempName[7], " VARN ", tempName[9][1:end-4]])
  save(string(title1,".pdf"),varyProcessPlot)
  save(string(title1,".svg"),varyProcessPlot)
  save(string(title1,".tex"),varyProcessPlot, include_preamble=false)
  cd("..") # in data
  cd(join([folder pdata]))# back in processed data folder
end

function format_data(A::Matrix)
  A1 = mean(abs.(A[:,1:Int(size(A)[2]/2)]),2)
  A2 = mean(abs.(A[:,Int(size(A)[2]/2)+1:end]),2)
  Afinal = [A1 A2]
  return Afinal
end


# Need to get 4 matrices of vars for all possible sims
# compute the 4 matrices for each one present --> store as a tuple in a sim array

if profile # plot the profiles for the runs
  # avg vs nSamples plots
  files = readdir() # in processed data for folder in main loop
  @show files

  filter!(x->x≠"total rewards",files) # remove total rewards folder
  # define all variables for plotting here so that they can be used outside the for loop
  tempName = split(files[1])
  #@show tempName
  offset = Int(length(files)/5) # dividing by 5 since 5 types of data for each sim
  if tempName[2] == "1D"
    states = 2
  elseif tempName[2] == "2D"
    states = 6 # last index of controllabel states for this problem
  end
  temp_st = Float64[]
  temp_est = Float64[]
  temp_ctrl = Float64[]
  temp_rew = Float64[]
  # add the variables for other simtypes
  conds = Int(offset/sim_types)
  for cond = 1:sim_types
      for i = 1:offset
        ctrlCur = Array(readtable(files[i])) # control effort # nSamples x 2*dimensions
        estCur = Array(readtable(files[i+offset])) # estimates
        rewCur = Array(readtable(files[i+2*offset])) # rewCur
        sCur = Array(readtable(files[i+3*offset])) # states
        difCur = estCur - sCur # take difference of est and current
        rewCur = rewCur[:,[1,3]]
        difS = sCur[:,1:states] # don't subtract state values --> want to see go to zero
        difE = difCur[:,1+states:end]
        difForm = format_data(difCur)
        curName = split(files[i]) # get words from conrol file
        # initialize the arrays that we will plot
        sim = curName[3]
        rollout = curName[4]
        temp_st = format_data(difS) # all of these are nSamples/nSamples+1 x 2 (avg and std)
        temp_est = format_data(difE)
        temp_ctrl = format_data(ctrlCur)
        temp_rew = rewCur

        if sim == "mcts" # add to the array of mcts to plot
          if rollout == "position"
            mcts_pos = (temp_st,temp_est,temp_ctrl,temp_rew)
            #@show size(mcts_pos)
          elseif rollout == "random"
            mcts_rand = (temp_st,temp_est,temp_ctrl,temp_rew)
          elseif rollout == "smooth"
            mcts_smooth = (temp_st,temp_est,temp_ctrl,temp_rew)
          end
        elseif sim == "mpc"
          if rollout == "fobs"
            mpc_fobs = (temp_st,temp_est,temp_ctrl,temp_rew)
          elseif rollout == "unk"
            mpc_unk = (temp_st,temp_est,temp_ctrl,temp_rew)
          end
        elseif sim == "qmdp"
          qmdp = (temp_st,temp_est,temp_ctrl,temp_rew)
        elseif sim == "nn"
          nn = (temp_st,temp_est,temp_ctrl,temp_rew)
        elseif sim == "dnn"
          dnn = (temp_st,temp_est,temp_ctrl,temp_rew)
        elseif sim == "adapt"
          adapt = (temp_st,temp_est,temp_ctrl,temp_rew)
        end # ADD HERE


      end # end of the 1:offset for loop.

      profile_st = PGFPlots.Plots.Linear[]
      profile_est = PGFPlots.Plots.Linear[]
      profile_ctrl = PGFPlots.Plots.Linear[]
      profile_rew = PGFPlots.Plots.Linear[]
      sim_list = (mcts_pos, mcts_rand, mcts_smooth, mpc_fobs, mpc_unk, qmdp, nn, dnn, adapt) # ADD HERE
      #@show size(temp_st), "is the first dim nSamples?"
      nSamples = size(temp_ctrl)[1]
      # loop through all sims and add all relevant ones to the plots
      for i in 1:length(sim_list)
        if length(sim_list[i]) != 0
          #sim_list[i] = 4x1 tuple --> [1-4] are st,est,ctrl,rew
          cp_st = Plots.Linear(0:nSamples-1,sim_list[i][1][1:nSamples,1], style=sim_style_list[i],  mark=mark1) # removed error bars cuz veloc & pos together are confusing: errorBars = ErrorBars(y=sim_list[i][1][1:nSamples,2]),
          cp_est = Plots.Linear(0:nSamples-1,sim_list[i][2][1:nSamples,1],errorBars = ErrorBars(y=sim_list[i][2][1:nSamples,2]), style=sim_style_list[i],  mark=mark1)
          cp_ctrl = Plots.Linear(0:nSamples-1,sim_list[i][3][:,1],errorBars = ErrorBars(y=sim_list[i][3][:,2]), style=sim_style_list[i],  mark=mark1)
          cp_rew = Plots.Linear(0:nSamples-1,sim_list[i][4][:,1],errorBars = ErrorBars(y=sim_list[i][4][:,2]), style=sim_style_list[i],  mark=mark1, legendentry=sim_leg_list[i])

          append!(profile_st, [cp_st])
          append!(profile_est, [cp_est])
          append!(profile_ctrl, [cp_ctrl])
          append!(profile_rew, [cp_rew])
        end
      end
      # adding horziontal lines at 0:
      start_zero_line = -1
      end_zero_line = nSamples+1
      append!(profile_st, [Plots.Linear([start_zero_line, end_zero_line],[0,0], style=col5,  mark=mark1)])
      append!(profile_est, [Plots.Linear([start_zero_line, end_zero_line],[0,0], style=col5,  mark=mark1)])
      append!(profile_ctrl, [Plots.Linear([start_zero_line, end_zero_line],[0,0], style=col5,  mark=mark1)])
      append!(profile_rew, [Plots.Linear([start_zero_line, end_zero_line],[0,0], style=col5,  mark=mark1)])


      #### Plot all 4 on a subplots
      stlab = "States"
      estlab = "Parameters"
      ctrllab = "Control"
      rewlab = "Reward"
      xaxis = "Steps (0.1 seconds)"
      vertspace = "0.5"
      horizspace = "0.0"
      ht = "4cm"
      ht2 = "6cm"
      wdth = "8cm"

      # determine if that type of data is available and then add it to the list to pass in if so

      st = Axis(profile_st
          #Plots.Linear(0:nSamples-1,mcts_pos_st[1:nSamples,1],errorBars = ErrorBars(y=mcts_pos_st[1:nSamples,2]), style=mcts_pos_style,  mark=mark1, legendentry=mcts_pos_leg)
          #Plots.Linear([0, nSamples-1],[0,0], style=col5,  mark=mark1)
          ,ylabel=stlab, width = wdth, height=ht)

      est = Axis(profile_est
          #Plots.Linear(0:nSamples-1,mcts_pos_est[1:nSamples,1],errorBars = ErrorBars(y=mcts_pos_est[1:nSamples,2]), style=mcts_pos_style,  mark=mark1)
          #Plots.Linear([0, nSamples-1],[0,0], style=col5,  mark=mark1)
          , ylabel=estlab, width = wdth, height=ht) #"Velocity (m/s)"

      ctrl = Axis(profile_ctrl
          #Plots.Linear(1:safeiters,LQG18[1:safeiters,var3+ex], style=mcts_pos_style,  mark=mark1)
          #Plots.Linear(0:nSamples-1,mcts_pos_ctrl[:,1],errorBars = ErrorBars(y=mcts_pos_ctrl[:,2]), style=mcts_pos_style,  mark=mark1)
          #Plots.Linear([0, nSamples-1],[0,0], style=col5,  mark=mark1)
          , ylabel=ctrllab, width = wdth, height=ht)

      rew = Axis(profile_rew
          #Plots.Linear(0:nSamples-1,mcts_pos_rew[:,1],errorBars = ErrorBars(y=mcts_pos_rew[:,2]), style=mcts_pos_style,  mark=mark1)
          ,xlabel=xaxis, ylabel=rewlab, legendPos="south east", width = wdth, height = ht2)

      g3 = GroupPlot(1,4, groupStyle = string("horizontal sep = ",horizspace,"cm, vertical sep = ",vertspace,"cm"))
      push!(g3, st)
      push!(g3, est)
      push!(g3, ctrl)
      push!(g3, rew)
      title_start = "PROF "
      title3 = join([folder,title_start, tempName[2], " PN ", tempName[6], " VARN ", tempName[8][1:end-4]])

      ####
      cd("..")
      try mkdir(plot_folder)
      end
      cd(plot_folder)
      save(string(title3,".pdf"),g3)
      save(string(title3,".svg"),g3)
      save(string(title3,".tex"),g3, include_preamble=false)
      cd("..")
      cd(join([folder pdata]))
  end # end of 1:offset loop now
  cd("..")
  cd(plot_folder)
end
cd("../..")
