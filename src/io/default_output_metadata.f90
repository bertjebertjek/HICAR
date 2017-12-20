module output_metadata

    use icar_constants
    use variable_interface,     only : variable_t
    use meta_data_interface,    only : attribute_t
    implicit none

    type(variable_t), allocatable :: var_meta(:)

    !>------------------------------------------------------------
    !! Generic interface to the netcdf read routines
    !!------------------------------------------------------------
    interface get_metadata
        module procedure get_metadata_2d, get_metadata_3d, get_metadata_nod
    end interface


contains

    function get_metadata_nod(var_idx) result(meta_data)
        implicit none
        integer, intent(in) :: var_idx
        type(variable_t) :: meta_data

        if (var_idx>kMAX_STORAGE_VARS) then
            stop "Invalid variable metadata requested"
        endif

        if (.not.allocated(var_meta)) call init_var_meta()

        meta_data = var_meta(var_idx)

        meta_data%two_d     = .False.
        meta_data%three_d   = .False.

    end function get_metadata_nod

    function get_metadata_2d(var_idx, input_data) result(meta_data)
        implicit none
        integer, intent(in) :: var_idx
        real,    intent(in), pointer :: input_data(:,:)
        type(variable_t) :: meta_data
        integer :: local_shape(2)

        if (var_idx>kMAX_STORAGE_VARS) then
            stop "Invalid variable metadata requested"
        endif

        if (.not.allocated(var_meta)) call init_var_meta()

        meta_data = var_meta(var_idx)

        meta_data%data_2d   => input_data
        meta_data%two_d     = .True.
        meta_data%three_d   = .False.
        local_shape(1) = size(input_data, 1)
        local_shape(2) = size(input_data, 2)
        ! for some reason is shape(input_data) is passed as source, then the dim_len bounds are (0:1) instead of 1:2
        allocate(meta_data%dim_len, source=local_shape)

    end function get_metadata_2d

    function get_metadata_3d(var_idx, input_data) result(meta_data)
        implicit none
        integer, intent(in) :: var_idx
        real,    intent(in), pointer :: input_data(:,:,:)
        type(variable_t) :: meta_data
        integer :: local_shape(3)

        if (var_idx>kMAX_STORAGE_VARS) then
            stop "Invalid variable metadata requested"
        endif

        if (.not.allocated(var_meta)) call init_var_meta()

        meta_data = var_meta(var_idx)

        meta_data%data_3d   => input_data
        meta_data%two_d     = .False.
        meta_data%three_d   = .True.
        local_shape(1) = size(input_data, 1)
        local_shape(2) = size(input_data, 3)
        local_shape(3) = size(input_data, 2)
        allocate(meta_data%dim_len, source=local_shape)

    end function get_metadata_3d


    subroutine init_var_meta()
        implicit none
        integer :: i

        if (allocated(var_meta)) deallocate(var_meta)

        if (kVARS%last_var/=kMAX_STORAGE_VARS) then
            stop "ERROR: variable indicies not correctly initialized"
        endif
        allocate(var_meta(kMAX_STORAGE_VARS))

        associate(var=>var_meta(kVARS%u))
            var%name        = "u"
            var%dimensions  = [character(len=16) :: "lon_u","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "grid_eastward_wind"),              &
                               attribute_t("long_name",     "Grid relative eastward wind"),     &
                               attribute_t("units",         "m s-1")]!,                           &
                               ! attribute_t("coordinates", "lat_u lon_u")]
        end associate
        associate(var=>var_meta(kVARS%v))
            var%name        = "v"
            var%dimensions  = [character(len=16) :: "lon_x","lat_v","level"]
            var%attributes  = [attribute_t("standard_name", "grid_northward_wind"),             &
                               attribute_t("long_name",     "Grid relative northward wind"),    &
                               attribute_t("units",         "m s-1")]!,                           &
                               ! attribute_t("coordinates", "lat_v lon_v")]
        end associate
        associate(var=>var_meta(kVARS%w))
            var%name        = "w"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "upward_air_velocity"),             &
                               attribute_t("long_name",     "Vertical wind"),                   &
                               attribute_t("units",         "m s-1"),                           &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%pressure))
            var%name        = "pressure"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "air_pressure"),                    &
                               attribute_t("long_name",     "Pressure"),                        &
                               attribute_t("units",         "Pa"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%pressure_interface))
            var%name        = "pressure_i"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level_i"]
            var%attributes  = [attribute_t("standard_name", "air_pressure"),                    &
                               attribute_t("long_name",     "Pressure"),                        &
                               attribute_t("units",         "Pa"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%potential_temperature))
            var%name        = "potential_temperature"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "air_potential_temperature"),       &
                               attribute_t("long_name",     "Potential Temperature"),           &
                               attribute_t("units",         "K"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%temperature))
            var%name        = "temperature"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "air_temperature"),                 &
                               attribute_t("long_name",     "Temperature"),                     &
                               attribute_t("units",         "K"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%water_vapor))
            var%name        = "qv"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "mass_fraction_of_water_vapor_in_air"), &
                               attribute_t("long_name",     "Water Vapor Mixing Ratio"),            &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%cloud_water))
            var%name        = "qc"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "cloud_liquid_water_mixing_ratio"),     &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%cloud_number_concentration))
            var%name        = "nc"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "number_concentration_of_cloud_droplets_in_air"), &
                               attribute_t("units",         "cm-3"),                                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%cloud_ice))
            var%name        = "qi"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "cloud_ice_mixing_ratio"),              &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%ice_number_concentration))
            var%name        = "ni"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "number_concentration_of_ice_crystals_in_air"), &
                               attribute_t("units",         "cm-3"),                                            &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%rain_in_air))
            var%name        = "qr"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "mass_fraction_of_rain_in_air"),        &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%rain_number_concentration))
            var%name        = "nr"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "number_concentration_of_rain_particles_in_air"), &
                               attribute_t("units",         "cm-3"),                                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%snow_in_air))
            var%name        = "qs"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "mass_fraction_of_snow_in_air"),        &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%snow_number_concentration))
            var%name        = "ns"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "number_concentration_of_snow_particles_in_air"), &
                               attribute_t("units",         "cm-3"),                                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%graupel_in_air))
            var%name        = "qg"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "mass_fraction_of_graupel_in_air"),     &
                               attribute_t("units",         "kg kg-1"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%graupel_number_concentration))
            var%name        = "ng"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "number_concentration_of_graupel_particles_in_air"), &
                               attribute_t("units",         "cm-3"),                                                 &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        ! associate(var=>var_meta(kVARS%precip_rate))
        !     var%name        = "precip_rate"
        !     var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
        !     var%attributes  = [attribute_t("standard_name",   "precipitation_flux"),      &
        !                        attribute_t("units",           "kg m-2 s-1"),              &
        !                        attribute_t("coordinates",     "lat lon")]
        ! end associate
        associate(var=>var_meta(kVARS%precipitation))
            var%name        = "precipitation"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "precipitation_amount"),                &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%snowfall))
            var%name        = "snowfall"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "snowfall_amount"),                     &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%graupel))
            var%name        = "graupel"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "graupel_amount"),                      &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%exner))
            var%name        = "exner"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "exner_function_result"),           &
                               attribute_t("units",         "K K-1"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%density))
            var%name        = "density"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "air_density"),                         &
                               attribute_t("units",         "kg m-3"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%z))
            var%name        = "z"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("standard_name", "height_above_reference_ellipsoid"),    &
                               attribute_t("units",         "m"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%z_interface))
            var%name        = "z_i"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level_i"]
            var%attributes  = [attribute_t("standard_name", "height_above_reference_ellipsoid"),    &
                               attribute_t("units",         "m"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%dz))
            var%name        = "dz"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level"]
            var%attributes  = [attribute_t("non_standard_name", "layer_thickness"),                 &
                               attribute_t("units",         "m"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%dz_interface))
            var%name        = "dz_i"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","level_i"]
            var%attributes  = [attribute_t("non_standard_name", "layer_thickness"),                 &
                               attribute_t("units",         "m"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%shortwave))
            var%name        = "rsds"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_downwelling_shortwave_flux_in_air"), &
                               attribute_t("units",         "W m-2"),                                     &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%longwave))
            var%name        = "rlds"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_downwelling_longwave_flux_in_air"), &
                               attribute_t("units",         "W m-2"),                                    &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%longwave_up))
            var%name        = "rlus"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_upwelling_longwave_flux_in_air"),   &
                               attribute_t("units",         "W m-2"),                                    &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%ground_heat_flux))
            var%name        = "hfgs"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "upward_heat_flux_at_ground_level_in_soil"), &
                               attribute_t("units",         "W m-2"),                                    &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%vegetation_fraction))
            var%name        = "vegetation_fraction"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "vegetation_fraction"),                 &
                               attribute_t("units",         "m2 m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%land_cover))
            var%name        = "land_cover"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("non_standard_name", "land_cover_type"),                 &
                               attribute_t("units",      ""),                                       &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%lai))
            var%name        = "lai"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("non_standard_name", "leaf_area_index"),                 &
                               attribute_t("units",         "m2 m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%canopy_water))
            var%name        = "canopy_water"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "canopy_water_amount"),                 &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%snow_water_equivalent))
            var%name        = "swe"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_snow_amount"),                 &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%soil_water_content))
            var%name        = "soil_water_content"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","nsoil"]
            var%attributes  = [attribute_t("standard_name", "soil_moisture_content"),               &
                               attribute_t("units",         "kg m-2"),                              &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%soil_temperature))
            var%name        = "soil_temperature"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x","nsoil"]
            var%attributes  = [attribute_t("standard_name", "soil_temperature"),                    &
                               attribute_t("units",         "K"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%air2m_temperature))
            var%name        = "ta2m"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "air_temperature"),                     &
                               attribute_t("long_name",     "Bulk air temperature at 2m"),          &
                               attribute_t("units",         "K"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%air2m_humidity))
            var%name        = "hus2m"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "specific_humidity"),                   &
                               attribute_t("units",         "kg kg-2"),                             &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%v10m))
            var%name        = "v10m"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "northward_10m_wind_speed"),            &
                               attribute_t("units",         "m s-1"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%u10m))
            var%name        = "u10m"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "eastward_10m_wind_speed"),             &
                               attribute_t("units",         "m s-1"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%skin_temperature))
            var%name        = "ts"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_temperature"),                 &
                               attribute_t("units",         "K"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%sensible_heat))
            var%name        = "hfss"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_upward_sensible_heat_flux"),   &
                               attribute_t("units",         "W m-2"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%latent_heat))
            var%name        = "hfls"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "surface_upward_latent_heat_flux"),     &
                               attribute_t("units",         "W m-2"),                               &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%land_mask))
            var%name        = "land_mask"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("non_standard_name", "land_water_mask"),                 &
                               attribute_t("coordinates",          "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%terrain))
            var%name        = "terrain"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "height_above_reference_ellipsoid"),    &
                               attribute_t("units",         "m"),                                   &
                               attribute_t("coordinates",   "lat lon")]
        end associate
        associate(var=>var_meta(kVARS%latitude))
            var%name        = "latitude"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "latitude"),                            &
                               attribute_t("units",         "degrees_north"),                       &
                               attribute_t("axis","Y")]
        end associate
        associate(var=>var_meta(kVARS%longitude))
            var%name        = "longitude"
            var%dimensions  = [character(len=16) :: "lon_x","lat_x"]
            var%attributes  = [attribute_t("standard_name", "longitude"),                           &
                               attribute_t("units",         "degrees_east"),                        &
                               attribute_t("axis","X")]
        end associate
        associate(var=>var_meta(kVARS%u_latitude))
            var%name        = "u_latitude"
            var%dimensions  = [character(len=16) :: "lon_u","lat_x"]
            var%attributes  = [attribute_t("non_standard_name", "latitude_on_u_grid"),              &
                               attribute_t("units",         "degrees_north")]
        end associate
        associate(var=>var_meta(kVARS%u_longitude))
            var%name        = "u_longitude"
            var%dimensions  = [character(len=16) :: "lon_u","lat_x"]
            var%attributes  = [attribute_t("non_standard_name", "longitude_on_u_grid"),             &
                               attribute_t("units",         "degrees_east")]
        end associate
        associate(var=>var_meta(kVARS%v_latitude))
            var%name        = "v_latitude"
            var%dimensions  = [character(len=16) :: "lon_x","lat_v"]
            var%attributes  = [attribute_t("non_standard_name", "latitude_on_v_grid"),              &
                               attribute_t("units",         "degrees_north")]
        end associate
        associate(var=>var_meta(kVARS%v_longitude))
            var%name        = "v_longitude"
            var%dimensions  = [character(len=16) :: "lon_x","lat_v"]
            var%attributes  = [attribute_t("non_standard_name", "longitude_on_v_grid"),             &
                               attribute_t("units",         "degrees_east")]
        end associate


        do i=1,size(var_meta)
            var_meta(i)%n_dimensions = size(var_meta(i)%dimensions)
            var_meta(i)%n_attrs      = size(var_meta(i)%attributes)
        enddo

    end subroutine init_var_meta

end module output_metadata
